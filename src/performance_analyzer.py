class PerformanceAnalyzer:
    def __init__(self):
        self.cycles = 0
        self.instructions = 0
        self.stalls = 0
        self.branch_mispredictions = 0
        self.cache_misses = 0
        
    def update(self, pipeline_state):
        self.cycles += 1
        if pipeline_state.instruction_completed:
            self.instructions += 1
        if pipeline_state.stall:
            self.stalls += 1
        if pipeline_state.branch_mispredict:
            self.branch_mispredictions += 1
            
    def get_statistics(self):
        return {
            "CPI": self.cycles / max(1, self.instructions),
            "Stall Rate": self.stalls / max(1, self.cycles),
            "Branch Mispredict Rate": self.branch_mispredictions / max(1, self.instructions),
            "Total Cycles": self.cycles,
            "Total Instructions": self.instructions
        } 