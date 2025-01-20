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
    // Change increment to 2 since memory module handles word addressing
    assign next_pc = pc + 16'd1;  // Changed from 2 to 1
    
    // PC update logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 16'b0;
        end
        else if (!stall) begin  // Check if we're not stalled
            if (jump_reg)
                pc <= jr_target;
            else if (jump)
                pc <= jump_target;
            else if (branch_taken)
                pc <= branch_target;
            else
                pc <= next_pc;  // Normal increment
        end
    end

    // Instruction memory instance
    instruction_memory imem (
        .addr(pc),     // Use PC directly since memory is word-addressed
        .inst(instruction)
    );
endmodule