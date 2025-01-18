`include "../defines.v"

module mem_stage (
    input  wire        clk,
    input  wire        rst_n,
    // Control signals
    input  wire        mem_read,
    input  wire        mem_write,
    // Data inputs
    input  wire [15:0] alu_result,
    input  wire [15:0] write_data,
    // Outputs
    output wire [15:0] read_data,
    output wire [15:0] mem_alu_result
);

    // Pass ALU result through
    assign mem_alu_result = alu_result;
    
    // Data memory instance
    data_memory dmem (
        .clk(clk),
        .rst_n(rst_n),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(alu_result[8:0]),  // Lower 9 bits for 512B memory
        .write_data(write_data),
        .read_data(read_data)
    );

endmodule