from visualizer import PipelineVisualizer

class Debugger:
    def __init__(self, pipeline):
        self.pipeline = pipeline
        self.visualizer = PipelineVisualizer()
        self.breakpoints = set()
        self.step_mode = False
        
    def add_breakpoint(self, address):
        self.breakpoints.add(address)
        
    def remove_breakpoint(self, address):
        self.breakpoints.discard(address)
        
    def step(self):
        """Execute one instruction"""
        if self.pipeline.pc < len(self.pipeline.instruction_memory.memory):
            instruction = self.pipeline.instruction_memory.load(self.pipeline.pc)
            self.pipeline.process_instruction(instruction)
            self.visualizer.display_pipeline_state(self.pipeline)
            self.visualizer.display_register_state(self.pipeline.registers)
            return True
        return False
        
    def run_until_breakpoint(self):
        """Run until next breakpoint or end of program"""
        while self.step():
            if self.pipeline.pc in self.breakpoints:
                print(f"Breakpoint hit at address {self.pipeline.pc}")
                break 