# Processor Configuration
WORD_SIZE = 16
NUM_REGISTERS = 8
INSTRUCTION_MEMORY_SIZE = 512  # bytes
DATA_MEMORY_SIZE = 512        # bytes
PIPELINE_STAGES = 5

# Memory Configuration
BYTE_ADDRESSABLE = True
WORD_ALIGNED = True

# Pipeline Configuration
ENABLE_FORWARDING = True
ENABLE_BRANCH_PREDICTION = True
BRANCH_PREDICTOR_TYPE = "static_not_taken"  # or "static_taken", "dynamic_1bit", "dynamic_2bit"

# Hazard Handling
ENABLE_DATA_HAZARD_DETECTION = True
ENABLE_CONTROL_HAZARD_DETECTION = True
STALL_PENALTY = 1
BRANCH_MISPREDICT_PENALTY = 2

# Debug Configuration
DEBUG_LEVEL = 1  # 0: None, 1: Basic, 2: Detailed
PRINT_PIPELINE_STATES = True
PRINT_MEMORY_ACCESSES = True
PRINT_REGISTER_CONTENTS = True 