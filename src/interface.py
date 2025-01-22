import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox
from assembler import Assembler
from pipeline import Pipeline
from instruction_set import decode_instruction
import sv_ttk

class ProcessorGUI:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("16-bit RISC Processor Simulator")
        self.root.geometry("1000x700")
        self.root.config(bg="#111111")

        self.pipeline = Pipeline()
        self.assembler = Assembler()
        self.create_widgets()
        self.current_step = 0
        style = ttk.Style(self.root)
        style.theme_use("clam")
        

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
            
        # Pipeline Stages Frame
        pipeline_frame = ttk.LabelFrame(right_frame, text="Pipeline Stages", padding="5")
        pipeline_frame.pack(fill=tk.X, pady=5)
        
        self.pipeline_labels = {}
        stages = ['IF', 'ID', 'EX', 'MEM', 'WB']
        self.stage_vars = {stage: tk.StringVar(value='-') for stage in stages}
        
        # Create grid for pipeline stages
        stage_frame = ttk.Frame(pipeline_frame)
        stage_frame.pack(fill=tk.X)
        for i, stage in enumerate(stages):
            ttk.Label(stage_frame, text=f"{stage}:").grid(row=0, column=i*2, padx=5)
            ttk.Label(stage_frame, textvariable=self.stage_vars[stage]).grid(row=0, column=i*2+1, padx=5)

        # Hazard Detection Frame
        hazard_frame = ttk.LabelFrame(right_frame, text="Hazards", padding="5")
        hazard_frame.pack(fill=tk.X, pady=5)
        self.hazard_text = scrolledtext.ScrolledText(hazard_frame, width=40, height=3)
        self.hazard_text.pack(pady=5)

        # Output paneli
        ttk.Label(right_frame, text="Output:").pack(anchor=tk.W)
        self.output_text = scrolledtext.ScrolledText(right_frame, width=50, height=20)
        self.output_text.pack(pady=5)

    def load_example(self):
        example_code = """
        # Data Hazard Test Program

# Initialize values
addi r1, r0, 30    # r1 = 30
addi r2, r0, 20    # r2 = 20

# RAW Hazard Tests
add  r3, r1, r2    # r3 = 50 (reads r1)
sub  r4, r3, r1    # r4 = 20 (RAW on r3)
add  r5, r4, r3    # r5 = 70 (RAW on r4)

# WAW Hazard Tests
addi r1, r0, 5     # r1 = 5  (overwriting r1)
add  r1, r2, r3    # r1 = 70 (WAW on r1)

# WAR Hazard Tests
add  r6, r2, r1    # r6 uses r2 before next instruction
addi r2, r0, 10    # r2 modified after being read

# Complex Dependencies
add  r7, r6, r1    # Depends on previous r6 and r1
sw   r7, 0(r6)     # Memory operation depending on r7
        """
        self.code_text.delete('1.0', tk.END)
        self.code_text.insert('1.0', example_code)

    def clear_all(self):
        self.code_text.delete('1.0', tk.END)
        self.output_text.delete('1.0', tk.END)
        for reg in self.register_vars:
            self.register_vars[reg].set('0')
        self.pc_var.set('0')
        self.current_step = 0
        self.hazard_text.delete('1.0', tk.END)

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
                self.pipeline.pc += 2
            else:
                messagebox.showinfo("Info", "All instructions have been executed.")
        except Exception as e:
            messagebox.showerror("Error", str(e))
            
    def detect_hazards(self, instruction):
        hazards = []
        
        # Check for RAW hazards
        if self.pipeline.ID_EX and self.pipeline.EX_MEM:
            if self.pipeline.ID_EX.rs == self.pipeline.EX_MEM.rd:
                hazards.append(f"RAW hazard: Register R{self.pipeline.ID_EX.rs}")
                
        # Check for WAW hazards
        if self.pipeline.ID_EX and self.pipeline.EX_MEM:
            if self.pipeline.ID_EX.rd == self.pipeline.EX_MEM.rd:
                hazards.append(f"WAW hazard: Register R{self.pipeline.ID_EX.rd}")
        
        return hazards

    def update_ui(self, instr):
        op, operands = decode_instruction(instr)
        self.output_text.insert(tk.END, f"Executed: {op} {operands}\n")

        # Update registers
        for i in range(8):
            self.register_vars[f'R{i}'].set(str(self.pipeline.registers[i]))

        # Update PC
        self.pc_var.set(str(self.pipeline.pc))
        
        stages = {
            'IF': self.pipeline.IF_ID.opcode if self.pipeline.IF_ID else '-',
            'ID': self.pipeline.ID_EX.opcode if self.pipeline.ID_EX else '-',
            'EX': self.pipeline.EX_MEM.opcode if self.pipeline.EX_MEM else '-',
            'MEM': self.pipeline.MEM_WB.opcode if self.pipeline.MEM_WB else '-',
            'WB': '-'
        }
        
        for stage, value in stages.items():
            self.stage_vars[stage].set(value)
            
        # Update hazards
        hazards = self.detect_hazards(instr)
        if hazards:
            self.hazard_text.insert(tk.END, "\n".join(hazards) + "\n")
            self.hazard_text.see(tk.END)

    def run(self):
        sv_ttk.use_dark_theme()
        self.root.mainloop()

if __name__ == "__main__":
    gui = ProcessorGUI()
    gui.run()
