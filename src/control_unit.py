# control_unit.py

def control_unit(opcode):
    """
    Generate control signals based on opcode
    Returns dict of control signals
    """
    signals = {
        'reg_write': 0,
        'mem_to_reg': 0,
        'mem_write': 0,
        'branch': 0,
        'alu_op': 'add',
        'alu_src': 0,
        'reg_dst': 0
    }
    
    if opcode in ["add", "sub", "and", "or", "slt"]:
        signals['reg_write'] = 1
        signals['reg_dst'] = 1
        signals['alu_op'] = opcode
    elif opcode == "lw":
        signals['reg_write'] = 1
        signals['mem_to_reg'] = 1
        signals['alu_src'] = 1
        signals['alu_op'] = 'add'
    elif opcode == "sw":
        signals['mem_write'] = 1
        signals['alu_src'] = 1
        signals['alu_op'] = 'add'
    elif opcode in ["beq", "bne"]:
        signals['branch'] = 1
        signals['alu_op'] = 'sub'
        
    return signals
