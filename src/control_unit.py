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
        'alu_op': '00',
        'alu_src': 0,
        'reg_dst': 0
    }
    
    if opcode == "add" or opcode == "sub":
        signals['reg_write'] = 1
        signals['reg_dst'] = 1
        signals['alu_op'] = '10'
    elif opcode == "lw":
        signals['reg_write'] = 1
        signals['mem_to_reg'] = 1
        signals['alu_src'] = 1
    elif opcode == "sw":
        signals['mem_write'] = 1
        signals['alu_src'] = 1
    elif opcode == "beq" or opcode == "bne":
        signals['branch'] = 1
        signals['alu_op'] = '01'
        
    return signals
