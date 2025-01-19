class DataMemory:
    def __init__(self):
        self.memory = [0] * 256  # 256 byte'lık bellek
        
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