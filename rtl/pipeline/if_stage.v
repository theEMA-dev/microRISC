`include "../defines.v"

module if_stage (
    input  wire        clk,
    input  wire        rst_n,
    // Control signals
    input  wire        stall,
    input  wire        branch_taken,
    input  wire        jump,
    input  wire        jump_reg,
    input  wire [15:0] branch_target,
    input  wire [15:0] jump_target,
    input  wire [15:0] jr_target,
    // Outputs
    output reg  [15:0] pc,
    output wire [15:0] next_pc,
    output wire [15:0] instruction
);

    assign next_pc = pc + 16'd2;  // PC+2 since instructions are 16-bit
    
    // PC update logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 16'b0;
        end
        else if (!stall) begin
            if (jump_reg)
                pc <= jr_target;
            else if (jump)
                pc <= jump_target;
            else if (branch_taken)
                pc <= branch_target;
            else
                pc <= next_pc;
        end
    end

    // Instruction memory instance
    instruction_memory imem (
        .addr(pc[8:0]),     // Lower 9 bits for 512B memory
        .inst(instruction)
    );

endmodule