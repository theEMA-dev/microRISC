from instruction_set import decode_instruction
from memory import DataMemory, InstructionMemory
from control_unit import ControlUnit
from alu_module import ALU

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
        self.registers = [0] * 8  # R0 her zaman 0
        self.data_memory = DataMemory()
        self.instruction_memory = InstructionMemory()
        self.control_unit = ControlUnit()
        self.alu = ALU()
        self.pc = 0
        
        self.IF_ID = PipelineRegister()
        self.ID_EX = PipelineRegister()
        self.EX_MEM = PipelineRegister()
        self.MEM_WB = PipelineRegister()
        
    def initialize_program(self, instructions):
        self.instruction_memory.store_program(instructions)
        self.pc = 0
        self.registers = [0] * 8  # Registerleri sıfırla
        
    def write_register(self, reg_num, value):
        """Register'a değer yaz (R0 hariç)"""
        if 0 <= reg_num < 8 and reg_num != 0:  # R0'a yazılamaz
            self.registers[reg_num] = value & 0xFFFF
            
    def read_register(self, reg_num):
        """Register'dan değer oku"""
        if 0 <= reg_num < 8:
            return self.registers[reg_num]
        return 0

    def process_instruction(self, instruction):
        try:
            self.MEM_WB = self.EX_MEM
            self.EX_MEM = self.ID_EX
            self.ID_EX = self.IF_ID
            opcode, operands = decode_instruction(instruction)
            signals = self.control_unit.get_control_signals(opcode)
            self.IF_ID = PipelineRegister()
            self.IF_ID.instruction = instruction
            self.IF_ID.opcode = opcode
            self.IF_ID.operands = operands
            
            if len(operands) >= 3:
                self.IF_ID.rd = operands[0]
                self.IF_ID.rs = operands[1]
                self.IF_ID.rt = operands[2]
            
            # R-type instructions
            if opcode in ["add", "sub", "and", "or", "slt"]:
                rd, rs, rt = operands
                val1 = self.read_register(rs)
                val2 = self.read_register(rt)
                result, _ = self.alu.execute(opcode, val1, val2)
                if signals["reg_write"]:
                    self.write_register(rd, result)
                    
            # I-type instructions
            elif opcode == "addi":
                rt, rs, imm = operands
                val1 = self.read_register(rs)
                result, _ = self.alu.execute(opcode, val1, imm)
                if signals["reg_write"]:
                    self.write_register(rt, result)
                    
            # Memory operations
            elif opcode == "lw":
                rt, rs, offset = operands
                addr = (self.read_register(rs) + offset) & 0xFF
                value = self.data_memory.load(addr)
                self.write_register(rt, value)
                
            elif opcode == "sw":
                rt, rs, offset = operands
                addr = (self.read_register(rs) + offset) & 0xFF
                value = self.read_register(rt)
                self.data_memory.store(addr, value)
                
            # Branch instructions
            elif opcode in ["beq", "bne"]:
                rs, rt, offset = operands
                val1 = self.read_register(rs)
                val2 = self.read_register(rt)
                is_equal = val1 == val2
                if (opcode == "beq" and is_equal) or (opcode == "bne" and not is_equal):
                    self.pc += offset
                    
            # Jump instructions
            elif opcode == "j":
                target = operands[0]
                self.pc = target
                
            elif opcode == "jal":
                target = operands[0]
                self.write_register(7, self.pc + 1)  # Return address in R7
                self.pc = target
                
            elif opcode == "jr":
                rs = operands[0]
                self.pc = self.read_register(rs)
                
            return True
            
        except Exception as e:
            print(f"Error processing instruction: {e}")
            return False

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
        print("\nRegisters:")
        for i in range(8):
            print(f"R{i}: {self.registers[i]}", end="  ")
            if (i + 1) % 4 == 0:
                print()
        print()

    def debug_memory(self):
        """Display memory contents"""
        print("\nMemory (first 16 bytes):")
        for i in range(0, 16, 2):
            value = self.data_memory.load(i)
            print(f"Addr {i:02x}: {value:04x}")

    # ... (keep other utility methods)
