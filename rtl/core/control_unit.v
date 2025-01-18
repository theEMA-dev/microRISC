`include "../defines.v"

module control_unit (
    input  wire [3:0] opcode,
    input  wire [2:0] funct,
    
    // Control signals
    output reg        reg_write,    // Register write enable
    output reg        mem_read,     // Memory read enable
    output reg        mem_write,    // Memory write enable
    output reg        mem_to_reg,   // Memory to register
    output reg        alu_src,      // ALU source select (0: register, 1: immediate)
    output reg  [3:0] alu_op,      // ALU operation
    output reg  [1:0] reg_dst,     // Register destination select (00: rd, 01: rt, 10: r7 for jal)
    output reg        branch,       // Branch instruction
    output reg        branch_ne,    // Branch not equal
    output reg        jump,         // Jump instruction
    output reg        jump_reg,     // Jump register instruction
    output reg        link          // Link instruction (JAL)
);

    always @(*) begin
        // Default values
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        alu_src    = 1'b0;
        alu_op     = 4'b0;
        reg_dst    = 2'b00;
        branch     = 1'b0;
        branch_ne  = 1'b0;
        jump       = 1'b0;
        jump_reg   = 1'b0;
        link       = 1'b0;

        case (opcode)
            `OP_R_TYPE: begin
                reg_write = 1'b1;
                reg_dst = 2'b00;    // Use rd field
                
                case (funct)
                    `FUNC_ADD: alu_op = `ALU_ADD;
                    `FUNC_SUB: alu_op = `ALU_SUB;
                    `FUNC_AND: alu_op = `ALU_AND;
                    `FUNC_OR:  alu_op = `ALU_OR;
                    `FUNC_SLT: alu_op = `ALU_SLT;
                    `FUNC_SLL: alu_op = `ALU_SLL;
                    `FUNC_SRL: alu_op = `ALU_SRL;
                endcase
            end
            
            `OP_ADDI: begin
                reg_write = 1'b1;
                reg_dst = 2'b01;    // Use rt field
                alu_src = 1'b1;     // Use immediate
                alu_op = `ALU_ADD;
            end
            
            `OP_LW: begin
                reg_write = 1'b1;
                reg_dst = 2'b01;    // Use rt field
                mem_read = 1'b1;
                mem_to_reg = 1'b1;
                alu_src = 1'b1;     // Use immediate
                alu_op = `ALU_ADD;
            end
            
            `OP_SW: begin
                mem_write = 1'b1;
                alu_src = 1'b1;     // Use immediate
                alu_op = `ALU_ADD;
            end
            
            `OP_BEQ: begin
                branch = 1'b1;
                branch_ne = 1'b0;
                alu_op = `ALU_SUB;
            end
            
            `OP_BNE: begin
                branch = 1'b1;
                branch_ne = 1'b1;
                alu_op = `ALU_SUB;
            end
            
            `OP_J: begin
                jump = 1'b1;
            end
            
            `OP_JAL: begin
                reg_write = 1'b1;
                reg_dst = 2'b10;    // Use R7 for return address
                jump = 1'b1;
                link = 1'b1;
            end
            
            `OP_JR: begin
                jump_reg = 1'b1;
            end
        endcase
    end

endmodule