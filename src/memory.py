class DataMemory:
    def __init__(self):
        self.memory = [0] * 512  # 512 bytes
        self.word_size = 16

    def load(self, address):
        if not 0 <= address < 512:
            raise ValueError(f"Memory address {address} out of bounds")
        # Convert byte address to word address (each word is 2 bytes)
        word_addr = address >> 1
        # Handle byte alignment
        is_upper_byte = (address & 1) == 0
        word = self.memory[word_addr]
        if is_upper_byte:
            return (word >> 8) & 0xFF
        else:
            return word & 0xFF

    def store(self, address, value):
        if not 0 <= address < 512:
            raise ValueError(f"Memory address {address} out of bounds")
        word_addr = address >> 1
        is_upper_byte = (address & 1) == 0
        word = self.memory[word_addr]
        if is_upper_byte:
            self.memory[word_addr] = (value << 8) | (word & 0xFF)
        else:
            self.memory[word_addr] = (word & 0xFF00) | (value & 0xFF)

class InstructionMemory:
    def __init__(self):
        self.memory = [0] * 256  # 512 bytes = 256 16-bit instructions

    def load(self, address):
        if not 0 <= address < 256:
            raise ValueError(f"Instruction address {address} out of bounds")
        return self.memory[address]

    def store_program(self, instructions):
        if len(instructions) > 256:
            raise ValueError("Program too large for instruction memory")
        for i, instr in enumerate(instructions):
            self.memory[i] = instr & 0xFFFF 