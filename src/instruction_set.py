# instruction_set.py

# Define opcodes for supported instructions
OPCODES = {
    "add": 0b0000,
    "sub": 0b0001,
    "and": 0b0010,
    "or": 0b0011,
    "slt": 0b0100,
    "sll": 0b0101,
    "srl": 0b0110,
    "addi": 0b0111,
    "lw": 0b1000,
    "sw": 0b1001,
    "beq": 0b1010,
    "bne": 0b1011,
    "j": 0b1100,
    "jal": 0b1101,
    "jr": 0b1110
}

def encode_instruction(op, rd=None, rs=None, rt=None, imm=None, shamt=None, target=None):
    """Encodes a given instruction into a 16-bit binary string."""
    opcode = OPCODES[op] << 12
    if op in {"add", "sub", "and", "or", "slt"}:  # R-type
        return opcode | (rs << 9) | (rt << 6) | (rd << 3)
    elif op in {"sll", "srl"}:  # R-type with shamt
        return opcode | (rt << 6) | (rd << 3) | shamt
    elif op in {"addi"}:  # I-type
        return opcode | (rs << 9) | (rt << 6) | (imm & 0x3F)
    elif op in {"lw", "sw"}:  # I-type with offset
        return opcode | (rs << 9) | (rt << 6) | (imm & 0x3F)
    elif op in {"beq", "bne"}:  # Branch
        return opcode | (rs << 9) | (rt << 6) | (imm & 0x3F)
    elif op == "j" or op == "jal":  # J-type
        return opcode | (target & 0xFFF)
    elif op == "jr":  # Jump register
        return opcode | (rs << 9)
    else:
        raise ValueError(f"Unsupported instruction: {op}")

def decode_instruction(encoded):
    """Decodes a 16-bit binary string into a human-readable instruction."""
    opcode = (encoded >> 12) & 0xF
    for key, value in OPCODES.items():
        if value == opcode:
            return key, encoded & 0xFFF
    return "UNKNOWN", None
