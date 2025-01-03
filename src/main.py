# main.py
from instruction_set import encode_instruction, decode_instruction

# Test instruction encoding
encoded = encode_instruction("add", rd=1, rs=2, rt=3)
print(f"Encoded 'add': {bin(encoded)[2:].zfill(16)}")

# Test instruction decoding
decoded_op, operands = decode_instruction(encoded)
print(f"Decoded: {decoded_op}, Operands: {bin(operands)[2:].zfill(12)}")


# main.py
from alu_module import alu

# Test ALU operations
print("Testing ALU:")
result, zero = alu("add", 10, 5)
print(f"ADD: 10 + 5 = {result}, Zero Flag = {zero}")

result, zero = alu("sub", 5, 5)
print(f"SUB: 5 - 5 = {result}, Zero Flag = {zero}")

result, zero = alu("and", 0b1100, 0b1010)
print(f"AND: 0b1100 & 0b1010 = {bin(result)}, Zero Flag = {zero}")

result, zero = alu("or", 0b1100, 0b1010)
print(f"OR: 0b1100 | 0b1010 = {bin(result)}, Zero Flag = {zero}")

result, zero = alu("slt", 3, 5)
print(f"SLT: 3 < 5 = {result}, Zero Flag = {zero}")


from control_unit import control_unit

# Test the control unit
print("\nTesting Control Unit:")
opcodes = ["add", "sub", "lw", "sw", "beq", "bne"]
for opcode in opcodes:
    signals = control_unit(opcode)
    print(f"Opcode: {opcode}, Control Signals: {signals}")


    from pipeline import Pipeline

# Create a pipeline instance
pipeline = Pipeline()

# Test sequence of instructions
instructions = ["add", "sub", "lw", "sw", "beq", "bne"]

for instruction in instructions:
    print(f"\nProcessing instruction: {instruction}")
    
    pipeline.stage_if(instruction)  # Instruction Fetch
    pipeline.stage_id()             # Instruction Decode
    pipeline.stage_ex()             # Execute
    pipeline.stage_mem()            # Memory Access
    pipeline.stage_wb()             # Write Back


