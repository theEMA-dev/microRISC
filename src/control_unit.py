# control_unit.py

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
        
        if opcode in ["add", "sub", "and", "or", "slt"]:
            signals["reg_write"] = True
            signals["alu_op"] = opcode
        elif opcode == "addi":
            signals["reg_write"] = True
            signals["alu_src"] = True
        elif opcode == "lw":
            signals["reg_write"] = True
            signals["mem_to_reg"] = True
            signals["alu_src"] = True
        elif opcode == "sw":
            signals["mem_write"] = True
            signals["alu_src"] = True
        elif opcode in ["beq", "bne"]:
            signals["branch"] = True
            signals["alu_op"] = "sub"
        elif opcode == "j":
            signals["jump"] = True
        elif opcode == "jal":
            signals["jump"] = True
            signals["link"] = True
            signals["reg_write"] = True
            
        return signals
