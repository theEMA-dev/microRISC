`include "../defines.v"

module wb_stage (
    // Control signal
    input  wire        mem_to_reg,
    // Data inputs
    input  wire [15:0] mem_read_data,
    input  wire [15:0] alu_result,
    // Output
    output wire [15:0] write_back_data
);

    // Select between memory data and ALU result
    assign write_back_data = mem_to_reg ? mem_read_data : alu_result;

endmodule