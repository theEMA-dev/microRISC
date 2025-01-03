from instruction_set import decode_instruction
from memory import DataMemory, InstructionMemory

class Registers:
    def __init__(self):
        self.registers = [0] * 8
    
    def read_register(self, reg_num):
        if not 0 <= reg_num < 8:
            raise ValueError(f"Invalid register number: {reg_num}")
        return self.registers[reg_num]
    
    def write_register(self, reg_num, value):
        if not 0 <= reg_num < 8:
            raise ValueError(f"Invalid register number: {reg_num}")
        if reg_num != 0:  # R0 is always 0
            self.registers[reg_num] = value & 0xFFFF

class ControlUnit:
    def get_control_signals(self, opcode):
        signals = {
            "reg_write": False,
            "mem_to_reg": False,
            "mem_write": False,
            "branch": False,
            "alu_op": "add",
            "alu_src": False,
            "jump": False,
            "link": False
        }
        
        # R-type instructions
        if opcode in ["add", "sub", "and", "or", "slt", "sll", "srl"]:
            signals["reg_write"] = True
            signals["alu_op"] = opcode
        
        # I-type instructions
        elif opcode == "addi":
            signals["reg_write"] = True
            signals["alu_src"] = True
            signals["alu_op"] = "add"
        elif opcode == "lw":
            signals["reg_write"] = True
            signals["mem_to_reg"] = True
            signals["alu_src"] = True
        elif opcode == "sw":
            signals["mem_write"] = True
            signals["alu_src"] = True
        
        # Branch instructions
        elif opcode in ["beq", "bne"]:
            signals["branch"] = True
            signals["alu_op"] = "sub"
        
        # Jump instructions
        elif opcode == "j":
            signals["jump"] = True
        elif opcode == "jal":
            signals["jump"] = True
            signals["link"] = True
            signals["reg_write"] = True
        elif opcode == "jr":
            signals["jump"] = True
            signals["alu_src"] = True
            
        return signals

class ALU:
    def execute(self, opcode, op1, op2):
        """
        Execute ALU operation
        op1: first operand
        op2: second operand or immediate value for I-type instructions
        """
        op1 = op1 & 0xFFFF
        op2 = op2 & 0xFFFF
        
        if opcode in ["add", "addi", "lw", "sw"]:  # Add load/store operations
            result = (op1 + op2) & 0xFFFF  # Base address + offset
        elif opcode == "sub":
            result = (op1 - op2) & 0xFFFF
        elif opcode == "and":
            result = op1 & op2
        elif opcode == "or":
            result = op1 | op2
        elif opcode == "slt":
            result = 1 if op1 < op2 else 0
        elif opcode == "sll":
            result = (op1 << op2) & 0xFFFF
        elif opcode == "srl":
            result = (op1 >> op2) & 0xFFFF
        else:
            raise ValueError(f"Unknown operation: {opcode}")
            
        zero_flag = (result == 0)
        return result, zero_flag

class PipelineRegister:
    def __init__(self):
        self.instruction = None  # Raw instruction
        self.opcode = None      # Decoded opcode
        self.operands = None    # Decoded operands
        self.rs = None
        self.rt = None
        self.rd = None
        self.value = 0         # Initialize to 0
        self.reg_write = False
        self.mem_to_reg = False
        self.mem_write = False
        self.branch = False
        self.alu_op = None
        self.alu_src = False
        self.jump = False
        self.link = False

    def __str__(self):
        opcode_str = self.opcode if self.opcode else "---"
        rs_str = f"r{self.rs}" if self.rs is not None else "---"
        rt_str = f"r{self.rt}" if self.rt is not None else "---"
        rd_str = f"r{self.rd}" if self.rd is not None else "---"
        val_str = f"0x{self.value:04x}"
        return f"{opcode_str:4} {rs_str:3} {rt_str:3} {rd_str:3} {val_str}"

    def clear(self):
        """Reset the pipeline register to initial state"""
        self.__init__()

class Pipeline:
    def __init__(self):
        self.registers = Registers()
        self.control_unit = ControlUnit()
        self.alu = ALU()
        self.data_memory = DataMemory()
        self.instruction_memory = InstructionMemory()
        
        # Initialize pipeline registers
        self.IF_ID = PipelineRegister()
        self.ID_EX = PipelineRegister()
        self.EX_MEM = PipelineRegister()
        self.MEM_WB = PipelineRegister()
        
        self.pc = 0
        self.control_signals = None
        self.stall_cycles = 0

    def initialize_program(self, instructions):
        """Load program into instruction memory and reset processor state"""
        # Reset program counter and pipeline registers
        self.pc = 0
        self.IF_ID.clear()
        self.ID_EX.clear()
        self.EX_MEM.clear()
        self.MEM_WB.clear()
        
        # Reset control signals
        self.control_signals = None
        self.stall_cycles = 0
        
        # Reset registers (except R0 which is always 0)
        for i in range(1, 8):
            self.registers.write_register(i, 0)
            
        # Load program into instruction memory
        self.instruction_memory.store_program(instructions)
        
        print(f"Initialized program with {len(instructions)} instructions")

    def stage_if(self, instruction):
        """Instruction fetch stage"""
        if_id = PipelineRegister()
        try:
            if self.pc < len(self.instruction_memory.memory):
                instruction = self.instruction_memory.load(self.pc)
                opcode, operands = decode_instruction(instruction)
                if_id.instruction = instruction
                if_id.opcode = opcode
                if_id.operands = operands
                self.pc += 1
        except Exception as e:
            print(f"IF stage error: {e}")
        return if_id

    def stage_id(self, if_id):
        """Instruction decode stage"""
        if not if_id or not if_id.opcode:
            return None
            
        try:
            self.control_signals = self.control_unit.get_control_signals(if_id.opcode)
            id_ex = PipelineRegister()
            id_ex.opcode = if_id.opcode
            id_ex.operands = if_id.operands
            
            # Extract register numbers
            if if_id.operands:
                if if_id.opcode in ["add", "sub", "and", "or", "slt"]:
                    id_ex.rd, id_ex.rs, id_ex.rt = if_id.operands
                elif if_id.opcode in ["sll", "srl"]:
                    id_ex.rd, id_ex.rt = if_id.operands[:2]
                elif if_id.opcode in ["addi", "lw", "sw"]:
                    id_ex.rt, id_ex.rs = if_id.operands[:2]
                elif if_id.opcode in ["beq", "bne"]:
                    id_ex.rs, id_ex.rt = if_id.operands[:2]
                elif if_id.opcode == "jr":
                    id_ex.rs = if_id.operands[0]
                    
            return id_ex
        except Exception as e:
            print(f"ID stage error: {e}")
            return None

    def stage_ex(self, id_ex):
        """Execute stage"""
        if not id_ex:
            return None
            
        try:
            ex_mem = PipelineRegister()
            ex_mem.opcode = id_ex.opcode
            
            # Get operand values
            op1 = self.registers.read_register(id_ex.rs) if id_ex.rs is not None else 0
            op2 = self.registers.read_register(id_ex.rt) if id_ex.rt is not None else 0
            
            # Execute operation
            result, zero_flag = self.alu.execute(id_ex.opcode, op1, op2)
            ex_mem.value = result
            ex_mem.rd = id_ex.rd
            
            return ex_mem
        except Exception as e:
            print(f"EX stage error: {e}")
            return None

    def stage_mem(self, ex_mem):
        """Memory access stage"""
        if not ex_mem:
            return None
            
        try:
            mem_wb = PipelineRegister()
            mem_wb.opcode = ex_mem.opcode
            mem_wb.value = ex_mem.value
            mem_wb.rd = ex_mem.rd
            
            if self.control_signals.get("mem_write"):
                self.data_memory.store(ex_mem.value, 0)  # Simplified memory access
            elif self.control_signals.get("mem_to_reg"):
                mem_wb.value = self.data_memory.load(ex_mem.value)
                
            return mem_wb
        except Exception as e:
            print(f"MEM stage error: {e}")
            return None

    def stage_wb(self, mem_wb):
        """Write back stage"""
        if not mem_wb or not mem_wb.rd:
            return
            
        try:
            if self.control_signals.get("reg_write"):
                self.registers.write_register(mem_wb.rd, mem_wb.value)
        except Exception as e:
            print(f"WB stage error: {e}")

    def process_instruction(self, instruction):
        """Process a single instruction through all pipeline stages"""
        try:
            # Pipeline stages
            self.IF_ID = self.stage_if(instruction)
            self.ID_EX = self.stage_id(self.IF_ID)
            self.EX_MEM = self.stage_ex(self.ID_EX)
            self.MEM_WB = self.stage_mem(self.EX_MEM)
            self.stage_wb(self.MEM_WB)
        except Exception as e:
            print(f"Pipeline error: {e}")

    def run_program(self, instructions):
        """Run a complete program"""
        self.initialize_program(instructions)
        while self.pc < len(instructions):
            instruction = self.instruction_memory.load(self.pc)
            print(f"\nExecuting instruction at PC={self.pc}:")
            self.process_instruction(instruction)
            self.debug_pipeline_registers()

    def debug_pipeline_registers(self):
        """Display current pipeline state"""
        print("\n=== Pipeline State ===")
        print("IF  ID  EX  MEM WB")
        print("-" * 20)
        
        # Show current instruction in each stage with safe formatting
        def format_stage(reg):
            if reg and hasattr(reg, 'opcode') and reg.opcode:
                return f"{reg.opcode:3}"
            return "---"
        
        stages = [
            format_stage(self.IF_ID),
            format_stage(self.ID_EX),
            format_stage(self.EX_MEM),
            format_stage(self.MEM_WB)
        ]
        print(" ".join(stages))
        
        # Show register contents
        print("\nRegisters:")
        for i in range(8):
            value = self.registers.read_register(i)
            print(f"R{i}: {value:04x}", end="  ")
            if (i + 1) % 4 == 0:
                print()
        
        # Show relevant memory contents
        print("\nMemory (first 8 words):")
        for i in range(0, 16, 2):
            try:
                addr = i // 2
                value = (self.data_memory.load(i) << 8) | self.data_memory.load(i+1)
                print(f"[{addr:02x}]: {value:04x}", end="  ")
                if (addr + 1) % 4 == 0:
                    print()
            except Exception as e:
                print(f"Error reading memory at {i}: {e}")

    def debug_memory(self):
        """Display memory contents"""
        print("\nData Memory (first 32 bytes):")
        for i in range(0, 32, 2):
            try:
                word = (self.data_memory.load(i) << 8) | self.data_memory.load(i+1)
                print(f"Address {i:03d}: {hex(word)[2:].zfill(4)}")
            except Exception as e:
                print(f"Error reading memory at {i}: {e}")

    # ... (keep other utility methods)
