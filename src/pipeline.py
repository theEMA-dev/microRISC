# pipeline.py

class Pipeline:
    def __init__(self):
        self.IF_ID = None  # Instruction Fetch/Instruction Decode Register
        self.ID_EX = None  # Instruction Decode/Execute Register
        self.EX_MEM = None # Execute/Memory Register
        self.MEM_WB = None # Memory/Write Back Register

    def clear(self):
        """Clear all pipeline registers"""
        self.IF_ID = None
        self.ID_EX = None
        self.EX_MEM = None
        self.MEM_WB = None

    def stage_if(self, instruction):
        """Instruction Fetch (IF) Stage: Fetch instruction from memory"""
        self.IF_ID = instruction
        print(f"IF: Fetched instruction: {instruction}")
        
    def stage_id(self):
        """Instruction Decode (ID) Stage: Decode instruction and fetch registers"""
        if self.IF_ID:
            instruction = self.IF_ID
            self.ID_EX = instruction
            print(f"ID: Decoded instruction: {instruction}")
            self.IF_ID = None  # Clear IF stage
        
    def stage_ex(self):
        """Execute (EX) Stage: Perform ALU operations"""
        if self.ID_EX:
            instruction = self.ID_EX
            self.EX_MEM = instruction  # Simple pass-through for now
            print(f"EX: Executing instruction: {instruction}")
            self.ID_EX = None  # Clear ID stage
        
    def stage_mem(self):
        """Memory Access (MEM) Stage: Access memory (for load/store)"""
        if self.EX_MEM:
            instruction = self.EX_MEM
            self.MEM_WB = instruction  # Simple pass-through for now
            print(f"MEM: Accessing memory for instruction: {instruction}")
            self.EX_MEM = None  # Clear EX stage
        
    def stage_wb(self):
        """Write Back (WB) Stage: Write the result back to registers"""
        if self.MEM_WB:
            instruction = self.MEM_WB
            print(f"WB: Writing back result for instruction: {instruction}")
            self.MEM_WB = None  # Clear MEM stage
