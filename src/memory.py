class DataMemory:
    def __init__(self):
        self.memory = [0] * 256  # 256 byte'lık bellek
        
    def reset(self):
        """Reset all memory contents to 0"""
        self.memory = [0] * 256
        
    def load(self, address):
        """Bellekten veri oku"""
        if 0 <= address < len(self.memory):
            return self.memory[address]
        raise ValueError(f"Invalid memory address: {address}")
        
    def store(self, address, value):
        """Belleğe veri yaz"""
        if 0 <= address < len(self.memory):
            self.memory[address] = value & 0xFF  # 8-bit değer
        else:
            raise ValueError(f"Invalid memory address: {address}")
        
    def get_memory_contents(self):
        contents = ""
        for addr in range(0, len(self.memory), 4):
            values = self.memory[addr:addr+4]
            if any(v != 0 for v in values):
                contents += f"0x{addr:03x}: {' '.join(f'{v:02x}' for v in values)}\n"
        return contents

class InstructionMemory:
    def __init__(self):
        self.memory = []
        
    def load(self, address):
        """Instruction'ı oku"""
        if 0 <= address < len(self.memory):
            return self.memory[address]
        raise ValueError(f"Invalid instruction address: {address}")
        
    def store_program(self, instructions):
        """Program instructionlarını yükle"""
        self.memory = instructions.copy() 
        
    def get_memory_contents(self):
        contents = ""
        for addr, instr in enumerate(self.memory):
            if instr:
                contents += f"0x{addr*2:03x}: {instr:04x}\n"
        return contents