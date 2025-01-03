import sys
from main import test_instruction_set, test_pipeline_stages, test_memory_system, test_hazards, test_branches
from assembler import Assembler
from pipeline import Pipeline

class ProcessorInterface:
    def __init__(self):
        self.pipeline = Pipeline()
        self.assembler = Assembler()

    def display_menu(self):
        print("\n=== 16-bit RISC Processor Interface ===")
        print("1. Run All Tests")
        print("2. Test Instruction Set")
        print("3. Test Pipeline Stages")
        print("4. Test Memory System")
        print("5. Test Hazard Handling")
        print("6. Test Branch Handling")
        print("7. Run Assembly Program")
        print("8. Exit")
        print("\nEnter your choice (1-8): ")

    def run_assembly_program(self):
        print("\n=== Assembly Program Execution ===")
        print("Enter your assembly program (end with an empty line):")
        print("Example:")
        print("addi R1, R0, 5")
        print("addi R2, R0, 3")
        print("add R3, R1, R2")
        print("")
        
        program_lines = []
        while True:
            line = input("> ").strip()
            if not line:
                break
            program_lines.append(line)

        if not program_lines:
            print("No program entered.")
            return

        try:
            # Assemble the program
            program = "\n".join(program_lines)
            instructions = self.assembler.assemble_program(program)
            
            # Run the program
            print("\nExecuting program...")
            self.pipeline.run_program(instructions)
            
        except Exception as e:
            print(f"Error: {e}")

    def run(self):
        while True:
            self.display_menu()
            try:
                choice = input().strip()
                
                if choice == '1':
                    print("\nRunning all tests...")
                    test_instruction_set()
                    test_pipeline_stages()
                    test_memory_system()
                    test_hazards()
                    test_branches()
                    
                elif choice == '2':
                    print("\nTesting instruction set...")
                    test_instruction_set()
                    
                elif choice == '3':
                    print("\nTesting pipeline stages...")
                    test_pipeline_stages()
                    
                elif choice == '4':
                    print("\nTesting memory system...")
                    test_memory_system()
                    
                elif choice == '5':
                    print("\nTesting hazard handling...")
                    test_hazards()
                    
                elif choice == '6':
                    print("\nTesting branch handling...")
                    test_branches()
                    
                elif choice == '7':
                    self.run_assembly_program()
                    
                elif choice == '8':
                    print("\nExiting...")
                    sys.exit(0)
                    
                else:
                    print("\nInvalid choice. Please try again.")
                    
                input("\nPress Enter to continue...")
                
            except Exception as e:
                print(f"\nError: {e}")
                input("\nPress Enter to continue...")

def main():
    interface = ProcessorInterface()
    interface.run()

if __name__ == "__main__":
    main() 