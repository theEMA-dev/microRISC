`include "../../defines.v"

module mem_wb_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        flush,
    // Control signals from MEM stage
    input  wire        mem_reg_write,
    input  wire        mem_mem_to_reg,
    // Data from MEM stage
    input  wire [15:0] mem_alu_result,
    input  wire [15:0] mem_read_data,
    input  wire [2:0]  mem_write_reg,
    // Control signals to WB stage
    output reg         wb_reg_write,
    output reg         wb_mem_to_reg,
    // Data to WB stage
    output reg  [15:0] wb_alu_result,
    output reg  [15:0] wb_read_data,
    output reg  [2:0]  wb_write_reg
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            // Control signals
            wb_reg_write  <= 1'b0;
            wb_mem_to_reg <= 1'b0;
            // Data
            wb_alu_result <= 16'b0;
            wb_read_data  <= 16'b0;
            wb_write_reg  <= 3'b0;
        end
        else begin
            // Control signals
            wb_reg_write  <= mem_reg_write;
            wb_mem_to_reg <= mem_mem_to_reg;
            // Data
            wb_alu_result <= mem_alu_result;
            wb_read_data  <= mem_read_data;
            wb_write_reg  <= mem_write_reg;
        end
    end

endmodule