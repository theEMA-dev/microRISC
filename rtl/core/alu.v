`include "../defines.v"

module alu (
    input  wire [15:0] a,          // First operand
    input  wire [15:0] b,          // Second operand
    input  wire [3:0]  alu_op,     // ALU operation
    output reg  [15:0] result,     // Result
    output wire        zero        // Zero flag for branch instructions
);

    // Zero flag is set when result is 0
    assign zero = (result == 16'b0);

    always @(*) begin
        case (alu_op)
            `ALU_ADD: result = a + b;
            `ALU_SUB: result = a - b;
            `ALU_AND: result = a & b;
            `ALU_OR:  result = a | b;
            `ALU_SLT: result = ($signed(a) < $signed(b)) ? 16'd1 : 16'd0;
            `ALU_SLL: result = b << a[3:0];  // Using lower 4 bits of a as shift amount
            `ALU_SRL: result = b >> a[3:0];  // Using lower 4 bits of a as shift amount
            default:  result = 16'b0;
        endcase
    end

endmodule