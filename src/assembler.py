from instruction_set import encode_instruction

class Assembler:
    def __init__(self):
        self.labels = {}
        self.current_address = 0
        
    def parse_line(self, line):
        """Parse a single assembly line"""
        # Remove comments and whitespace
        line = line.split('#')[0].strip()
        if not line:
            return None
            
        # Check for labels
        if ':' in line:
            label, rest = line.split(':')
            self.labels[label.strip()] = self.current_address
            line = rest.strip()
            if not line:
                return None
            
        # Parse instruction
        parts = line.replace(',', ' ').split()
        if not parts:
            return None
            
        opcode = parts[0].lower()
        
        try:
            # R-type instructions
            if opcode in ['add', 'sub', 'and', 'or', 'slt']:
                rd = int(parts[1][1:])  # Remove 'R' prefix
                rs = int(parts[2][1:])
                rt = int(parts[3][1:])
                return encode_instruction(opcode, rd=rd, rs=rs, rt=rt)
                
            # Shift instructions
            elif opcode in ['sll', 'srl']:
                rd = int(parts[1][1:])
                rt = int(parts[2][1:])
                shamt = int(parts[3])
                return encode_instruction(opcode, rd=rd, rt=rt, shamt=shamt)
                
            # I-type instructions
            elif opcode == 'addi':
                rt = int(parts[1][1:])
                rs = int(parts[2][1:])
                imm = int(parts[3])
                return encode_instruction(opcode, rt=rt, rs=rs, imm=imm)
                
            # Memory instructions
            elif opcode in ['lw', 'sw']:
                rt = int(parts[1][1:])
                offset_base = parts[2].split('(')
                offset = int(offset_base[0])
                rs = int(offset_base[1].strip(')')[1:])
                return encode_instruction(opcode, rt=rt, rs=rs, imm=offset)
                
            # Branch instructions
            elif opcode in ['beq', 'bne']:
                rs = int(parts[1][1:])
                rt = int(parts[2][1:])
                label = parts[3]
                if label in self.labels:
                    offset = self.labels[label] - (self.current_address + 1)
                    return encode_instruction(opcode, rs=rs, rt=rt, imm=offset)
                else:
                    raise ValueError(f"Undefined label: {label}")
                    
            # Jump instructions
            elif opcode == 'j':
                if parts[1] in self.labels:
                    target = self.labels[parts[1]]
                    return encode_instruction(opcode, target=target)
                else:
                    target = int(parts[1], 0)  # Support hex/decimal
                    return encode_instruction(opcode, target=target)
                    
            elif opcode == 'jal':
                if parts[1] in self.labels:
                    target = self.labels[parts[1]]
                    return encode_instruction(opcode, target=target)
                else:
                    target = int(parts[1], 0)
                    return encode_instruction(opcode, target=target)
                    
            elif opcode == 'jr':
                rs = int(parts[1][1:])
                return encode_instruction(opcode, rs=rs)
                
            else:
                raise ValueError(f"Unknown instruction: {opcode}")
                
        except (IndexError, ValueError) as e:
            raise ValueError(f"Error parsing instruction '{line}': {str(e)}")

    def assemble_program(self, assembly_code):
        """Convert assembly program to machine code"""
        instructions = []
        # First pass: collect labels
        for line in assembly_code.split('\n'):
            if ':' in line:
                label, _ = line.split(':')
                self.labels[label.strip()] = len(instructions)
                
        # Second pass: generate machine code
        self.current_address = 0
        for line in assembly_code.split('\n'):
            instruction = self.parse_line(line)
            if instruction is not None:
                instructions.append(instruction)
                self.current_address += 1
                
        return instructions 