import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox
from assembler import Assembler
from pipeline import Pipeline
from instruction_set import decode_instruction

class ProcessorGUI:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("16-bit RISC Processor Simulator")
        self.root.geometry("1000x700")
        
        self.pipeline = Pipeline()
        self.assembler = Assembler()
        self.create_widgets()
        
    def create_widgets(self):
        # Ana frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Sol panel (Assembly kodu ve butonlar)
        left_frame = ttk.Frame(main_frame)
        left_frame.grid(row=0, column=0, padx=5, sticky=tk.N)
        
        ttk.Label(left_frame, text="Assembly Code:").pack(anchor=tk.W)
        self.code_text = scrolledtext.ScrolledText(left_frame, width=40, height=15)
        self.code_text.pack(pady=5)
        
        # Butonlar
        button_frame = ttk.Frame(left_frame)
        button_frame.pack(fill=tk.X, pady=5)
        
        ttk.Button(button_frame, text="Load Example", command=self.load_example).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Run Code", command=self.run_code).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Clear All", command=self.clear_all).pack(side=tk.LEFT, padx=5)
        
        # Sağ panel (Registers ve Output)
        right_frame = ttk.Frame(main_frame)
        right_frame.grid(row=0, column=1, padx=5, sticky=tk.N)
        
        # Register paneli
        register_frame = ttk.LabelFrame(right_frame, text="Registers", padding="5")
        register_frame.pack(fill=tk.X, pady=5)
        
        self.register_vars = {}
        for i in range(8):
            frame = ttk.Frame(register_frame)
            frame.pack(fill=tk.X)
            ttk.Label(frame, text=f"R{i}:").pack(side=tk.LEFT, padx=5)
            self.register_vars[f'R{i}'] = tk.StringVar(value='0')
            ttk.Label(frame, textvariable=self.register_vars[f'R{i}']).pack(side=tk.LEFT)
        
        # Output paneli
        ttk.Label(right_frame, text="Output:").pack(anchor=tk.W)
        self.output_text = scrolledtext.ScrolledText(right_frame, width=50, height=20)
        self.output_text.pack(pady=5)
        
    def load_example(self):
        example_code = """# Example program
addi R1, R0, 5    # R1 = 5
addi R2, R0, 3    # R2 = 3
add R3, R1, R2    # R3 = R1 + R2
sw R3, 0(R1)      # Store R3 in memory
lw R4, 0(R1)      # Load from memory to R4"""
        self.code_text.delete('1.0', tk.END)
        self.code_text.insert('1.0', example_code)
        
    def clear_all(self):
        self.code_text.delete('1.0', tk.END)
        self.output_text.delete('1.0', tk.END)
        for reg in self.register_vars:
            self.register_vars[reg].set('0')
            
    def run_code(self):
        try:
            self.output_text.delete('1.0', tk.END)
            code = self.code_text.get('1.0', tk.END)
            
            # Kodu derle
            instructions = self.assembler.assemble_program(code)
            
            # Pipeline'ı başlat
            self.pipeline.initialize_program(instructions)
            
            # Sonuçları göster
            self.output_text.insert(tk.END, "=== Assembled Instructions ===\n\n")
            for i, instr in enumerate(instructions):
                op, operands = decode_instruction(instr)
                binary = format(instr, '016b')
                self.output_text.insert(tk.END, f"Instruction {i}:\n")
                self.output_text.insert(tk.END, f"Binary: {binary}\n")
                self.output_text.insert(tk.END, f"Decoded: {op} {operands}\n\n")
            
            # Komutları çalıştır
            self.output_text.insert(tk.END, "=== Execution Results ===\n\n")
            for instr in instructions:
                self.pipeline.process_instruction(instr)
                op, operands = decode_instruction(instr)
                self.output_text.insert(tk.END, f"Executed: {op} {operands}\n")
                
                # Her komuttan sonra register değerlerini göster
                self.output_text.insert(tk.END, "Registers: ")
                for i in range(8):
                    value = self.pipeline.registers[i]
                    self.output_text.insert(tk.END, f"R{i}={value} ")
                self.output_text.insert(tk.END, "\n\n")
            
            # Register panelini güncelle
            for i in range(8):
                self.register_vars[f'R{i}'].set(str(self.pipeline.registers[i]))
                
        except Exception as e:
            messagebox.showerror("Error", str(e))
            
    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    gui = ProcessorGUI()
    gui.run() 