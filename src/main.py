# main.py
from instruction_set import encode_instruction, decode_instruction
from pipeline import Pipeline, ALU, ControlUnit
from memory import DataMemory
from assembler import Assembler

def test_instruction_set():
    """Test all supported instructions"""
    print("\n=== Testing Instruction Set ===")
    test_cases = [
        # R-type instructions
        ("add", {"rd": 1, "rs": 2, "rt": 3}),
        ("sub", {"rd": 2, "rs": 3, "rt": 4}),
        ("and", {"rd": 3, "rs": 4, "rt": 5}),
        ("or", {"rd": 4, "rs": 5, "rt": 6}),
        ("slt", {"rd": 5, "rs": 6, "rt": 7}),
        
        # Shift instructions
        ("sll", {"rd": 1, "rt": 2, "shamt": 2}),
        ("srl", {"rd": 2, "rt": 3, "shamt": 2}),
        
        # I-type instructions (6-bit immediate)
        ("addi", {"rt": 1, "rs": 0, "imm": 5}),
        ("lw", {"rt": 2, "rs": 1, "imm": 4}),
        ("sw", {"rt": 3, "rs": 1, "imm": 4}),
        
        # Branch instructions (6-bit offset)
        ("beq", {"rs": 1, "rt": 2, "imm": 4}),
        ("bne", {"rs": 2, "rt": 3, "imm": 4}),
        
        # Jump instructions (12-bit target)
        ("j", {"target": 0x20}),
        ("jal", {"target": 0x30}),
        ("jr", {"rs": 7})
    ]
    
    for op, args in test_cases:
        try:
            encoded = encode_instruction(op, **args)
            decoded_op, operands = decode_instruction(encoded)
            print(f"{op:4} {args}")
            print(f"Encoded: {bin(encoded)[2:].zfill(16)}")
            print(f"Decoded: {decoded_op}, {operands}\n")
        except Exception as e:
            print(f"Error testing {op}: {e}\n")

def test_pipeline_stages():
    """Test pipeline stages and hazard handling"""
    print("\n=== Testing Pipeline Stages ===")
    pipeline = Pipeline()
    
    # Test program with data hazards
    test_program = [
        encode_instruction("addi", rt=1, rs=0, imm=5),   # R1 = 5
        encode_instruction("addi", rt=2, rs=0, imm=3),   # R2 = 3
        encode_instruction("add", rd=3, rs=1, rt=2),     # R3 = R1 + R2 (8)
        encode_instruction("add", rd=4, rs=3, rt=1),     # R4 = R3 + R1 (13) - RAW hazard
        encode_instruction("sw", rt=4, rs=2, imm=0),     # M[R2] = R4
        encode_instruction("lw", rt=5, rs=2, imm=0),     # R5 = M[R2] - Load hazard
        encode_instruction("beq", rs=1, rt=2, imm=2),    # Branch hazard
        encode_instruction("add", rd=6, rs=4, rt=5)      # May be skipped
    ]
    
    pipeline.initialize_program(test_program)
    
    print("Executing pipeline stages:")
    for i, instruction in enumerate(test_program):
        print(f"\nCycle {i+1}:")
        print(f"Instruction: {bin(instruction)[2:].zfill(16)}")
        op, operands = decode_instruction(instruction)
        print(f"Executing: {op} {operands}")
        
        pipeline.process_instruction(instruction)
        pipeline.debug_pipeline_registers()

def test_memory_system():
    """Test memory operations"""
    print("\n=== Testing Memory System ===")
    pipeline = Pipeline()
    
    # Initialize some data in memory (using smaller values)
    data_mem = pipeline.data_memory
    for i in range(0, 8, 2):
        data_mem.store(i, i+1)
    
    # Test program with memory operations
    test_program = [
        encode_instruction("addi", rt=1, rs=0, imm=4),   # Base address
        encode_instruction("sw", rt=1, rs=1, imm=0),     # Store
        encode_instruction("lw", rt=2, rs=1, imm=0),     # Load
        encode_instruction("sw", rt=2, rs=1, imm=2)      # Store to next word
    ]
    
    pipeline.initialize_program(test_program)
    print("Memory contents before execution:")
    pipeline.debug_memory()
    
    for instruction in test_program:
        pipeline.process_instruction(instruction)
    
    print("\nMemory contents after execution:")
    pipeline.debug_memory()

def test_hazards():
    """Test data hazards and forwarding"""
    print("\n=== Testing Hazard Handling ===")
    pipeline = Pipeline()
    
    # Test RAW hazards
    test_program = [
        encode_instruction("addi", rt=1, rs=0, imm=5),   # R1 = 5
        encode_instruction("add", rd=2, rs=1, rt=1),     # R2 = R1 + R1 (RAW hazard)
        encode_instruction("add", rd=3, rs=2, rt=1),     # R3 = R2 + R1 (RAW hazard)
    ]
    
    pipeline.initialize_program(test_program)
    print("Testing RAW Hazards:")
    for i, instruction in enumerate(test_program):
        print(f"\nCycle {i+1}:")
        pipeline.process_instruction(instruction)
        pipeline.debug_pipeline_registers()

def test_branches():
    """Test branch prediction and control hazards"""
    print("\n=== Testing Branch Handling ===")
    pipeline = Pipeline()
    
    # Test branch prediction
    test_program = [
        encode_instruction("addi", rt=1, rs=0, imm=5),   # R1 = 5
        encode_instruction("addi", rt=2, rs=0, imm=5),   # R2 = 5
        encode_instruction("beq", rs=1, rt=2, imm=2),    # Should branch
        encode_instruction("add", rd=3, rs=1, rt=2),     # Should be skipped
        encode_instruction("sub", rd=3, rs=1, rt=2),     # Branch target
    ]
    
    pipeline.initialize_program(test_program)
    print("Testing Branch Prediction:")
    for i, instruction in enumerate(test_program):
        print(f"\nCycle {i+1}:")
        pipeline.process_instruction(instruction)
        pipeline.debug_pipeline_registers()

if __name__ == "__main__":
    print("=== 16-bit RISC Processor Testing ===")
    test_instruction_set()
    test_pipeline_stages()
    test_memory_system()
    test_hazards()
    test_branches()
