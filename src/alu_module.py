# alu_module.py

def alu(operation, a, b):
    """
    ALU operations for 16-bit RISC processor
    Returns: (result, zero_flag)
    """
    # Ensure inputs are 16-bit values
    a = a & 0xFFFF
    b = b & 0xFFFF
    
    if operation == "add":
        result = (a + b) & 0xFFFF
    elif operation == "sub":
        result = (a - b) & 0xFFFF
    elif operation == "and":
        result = a & b
    elif operation == "or":
        result = a | b
    elif operation == "slt":
        result = 1 if a < b else 0
    else:
        raise ValueError(f"Unsupported operation: {operation}")
    
    zero_flag = (result == 0)
    return result, zero_flag
