from instruction_set import encode_instruction, decode_instruction
from pipeline import Pipeline
from memory import DataMemory, InstructionMemory

class TestSuite:
    @staticmethod
    def run_all_tests():
        print("=== Running Complete Test Suite ===\n")
        
        # Initialize test program
        test_program = [
            # Data Processing Instructions
            encode_instruction("add", rd=1, rs=2, rt=3),
            encode_instruction("sub", rd=2, rs=3, rt=4),
            encode_instruction("and", rd=3, rs=4, rt=5),
            encode_instruction("or", rd=4, rs=5, rt=6),
            encode_instruction("slt", rd=5, rs=6, rt=7),
            
            # Memory Access Instructions
            encode_instruction("lw", rt=1, rs=2, imm=4),
            encode_instruction("sw", rt=3, rs=4, imm=8),
            
            # Branch Instructions
            encode_instruction("beq", rs=1, rt=2, imm=4),
            encode_instruction("bne", rs=3, rt=4, imm=8),
            
            # Jump Instructions
            encode_instruction("j", target=0x100),
            encode_instruction("jal", target=0x200),
            encode_instruction("jr", rs=7)
        ]
        
        pipeline = Pipeline()
        pipeline.initialize_program(test_program)
        
        # Run program and collect statistics
        pipeline.run_program(test_program) 