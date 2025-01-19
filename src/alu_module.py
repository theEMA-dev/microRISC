# alu_module.py

class ALU:
    def execute(self, opcode, op1, op2):
        op1 = op1 & 0xFFFF
        op2 = op2 & 0xFFFF
        
        if opcode in ["add", "addi", "lw", "sw"]:
            result = (op1 + op2) & 0xFFFF
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
            raise ValueError(f"Unknown ALU operation: {opcode}")
            
        zero_flag = (result == 0)
        return result, zero_flag
