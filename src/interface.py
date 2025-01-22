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
        self.current_step = 0

    def create_widgets(self):
        # Ana frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Sol panel (Assembly kodu ve butonlar)
        left_frame = ttk.Frame(main_frame)
        left_frame.grid(row=0, column=0, padx=5, sticky=tk.N)

        ttk.Label(left_frame, text="Assembly Code:").pack(anchor=tk.W)
        self.code_text = scrolledtext.ScrolledText(left_frame, width=40, height=15, bg="black", fg="white")
        self.code_text.pack(pady=5)

        # Butonlar
        button_frame = ttk.Frame(left_frame)
        button_frame.pack(fill=tk.X, pady=5)

        ttk.Button(button_frame, text="Load Example", command=self.load_example).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Run Code", command=self.run_code).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Step", command=self.step_code).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Clear All", command=self.clear_all).pack(side=tk.LEFT, padx=5)

        # Sağ panel (Registers, Output ve PC)
        right_frame = ttk.Frame(main_frame)
        right_frame.grid(row=0, column=1, padx=5, sticky=tk.N)

        # Program Counter (PC)
        pc_frame = ttk.LabelFrame(right_frame, text="Program Counter", padding="5")
        pc_frame.pack(fill=tk.X, pady=5)
        self.pc_var = tk.StringVar(value='0')
        ttk.Label(pc_frame, text="PC:").pack(side=tk.LEFT, padx=5)
        ttk.Label(pc_frame, textvariable=self.pc_var).pack(side=tk.LEFT)

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
        self.output_text = scrolledtext.ScrolledText(right_frame, width=50, height=20, bg="black", fg="white")
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
        self.pc_var.set('0')
        self.current_step = 0

    def run_code(self):
        try:
            self.output_text.delete('1.0', tk.END)
            code = self.code_text.get('1.0', tk.END)

            # Kodu derle
            instructions = self.assembler.assemble_program(code)

            # Pipeline'ı başlat
            self.pipeline.initialize_program(instructions)

            # Komutları çalıştır
            self.output_text.insert(tk.END, "=== Execution Results ===\n\n")
            for instr in instructions:
                self.pipeline.process_instruction(instr)
                self.update_ui(instr)

        except Exception as e:
            messagebox.showerror("Error", str(e))

    def step_code(self):
        try:
            code = self.code_text.get('1.0', tk.END)
            if self.current_step == 0:
                self.instructions = self.assembler.assemble_program(code)
                self.pipeline.initialize_program(self.instructions)

            if self.current_step < len(self.instructions):
                instr = self.instructions[self.current_step]
                self.pipeline.process_instruction(instr)
                self.update_ui(instr)
                self.current_step += 1
            else:
                messagebox.showinfo("Info", "All instructions have been executed.")
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def update_ui(self, instr):
        op, operands = decode_instruction(instr)
        self.output_text.insert(tk.END, f"Executed: {op} {operands}\n")

        # Update registers
        for i in range(8):
            self.register_vars[f'R{i}'].set(str(self.pipeline.registers[i]))

        # Update PC
        self.pc_var.set(str(self.pipeline.pc))

    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    gui = ProcessorGUI()
    gui.run()
