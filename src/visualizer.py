class PipelineVisualizer:
    @staticmethod
    def display_pipeline_state(pipeline):
        print("\n=== Pipeline State ===")
        print("IF  ID  EX  MEM WB")
        print("-" * 20)
        
        # Display current instruction in each stage
        stages = [
            pipeline.IF_ID.opcode if pipeline.IF_ID else "-",
            pipeline.ID_EX.opcode if pipeline.ID_EX else "-",
            pipeline.EX_MEM.opcode if pipeline.EX_MEM else "-",
            pipeline.MEM_WB.opcode if pipeline.MEM_WB else "-"
        ]
        print(" ".join(f"{s:3}" for s in stages))
        
    @staticmethod
    def display_memory_state(data_memory, start_addr=0, num_words=8):
        print("\n=== Memory State ===")
        for i in range(start_addr, start_addr + num_words * 2, 2):
            word = (data_memory.load(i) << 8) | data_memory.load(i+1)
            print(f"Addr {i:03x}: {word:04x}")
            
    @staticmethod
    def display_register_state(registers):
        print("\n=== Register State ===")
        for i in range(8):
            value = registers.read_register(i)
            print(f"R{i}: {value:04x}") 