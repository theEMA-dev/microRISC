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
    # Validate register numbers
    if rd is not None and not 0 <= rd < 8:  # 3-bit register addresses
        raise ValueError(f"Invalid destination register: {rd}")
    if rs is not None and not 0 <= rs < 8:
        raise ValueError(f"Invalid source register 1: {rs}")
    if rt is not None and not 0 <= rt < 8:
        raise ValueError(f"Invalid source register 2: {rt}")
        
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
    """Decodes a 16-bit binary string into a human-readable instruction and operands."""
    opcode = (encoded >> 12) & 0xF
    
    # Find the operation
    op = None
    for key, value in OPCODES.items():
        if value == opcode:
            op = key
            break
    
    if op is None:
        return "UNKNOWN", None
        
    # Extract operands based on instruction type
    if op in {"add", "sub", "and", "or", "slt"}:  # R-type
        rs = (encoded >> 9) & 0x7
        rt = (encoded >> 6) & 0x7
        rd = (encoded >> 3) & 0x7
        return op, [rd, rs, rt]
    elif op in {"sll", "srl"}:  # R-type with shamt
        rt = (encoded >> 6) & 0x7
        rd = (encoded >> 3) & 0x7
        shamt = encoded & 0x7
        return op, [rd, rt, shamt]
    elif op in {"addi", "lw", "sw"}:  # I-type
        rs = (encoded >> 9) & 0x7
        rt = (encoded >> 6) & 0x7
        imm = encoded & 0x3F
        return op, [rt, rs, imm]
    elif op in {"beq", "bne"}:  # Branch
        rs = (encoded >> 9) & 0x7
        rt = (encoded >> 6) & 0x7
        offset = encoded & 0x3F
        return op, [rs, rt, offset]
    elif op in {"j", "jal"}:  # J-type
        target = encoded & 0xFFF
        return op, [target]
    elif op == "jr":  # Jump register
        rs = (encoded >> 9) & 0x7
        return op, [rs]
    else:
        return "UNKNOWN", None
