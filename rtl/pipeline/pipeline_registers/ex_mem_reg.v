`include "../../defines.v"

module ex_mem_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        flush,
    // Control signals from EX stage
    input  wire        ex_reg_write,
    input  wire        ex_mem_read,
    input  wire        ex_mem_write,
    input  wire        ex_mem_to_reg,
    // Data from EX stage
    input  wire [15:0] ex_alu_result,
    input  wire [15:0] ex_reg2_data,    // Store data for sw
    input  wire [2:0]  ex_write_reg,    // Destination register
    // Control signals to MEM stage
    output reg         mem_reg_write,
    output reg         mem_mem_read,
    output reg         mem_mem_write,
    output reg         mem_mem_to_reg,
    // Data to MEM stage
    output reg  [15:0] mem_alu_result,
    output reg  [15:0] mem_write_data,
    output reg  [2:0]  mem_write_reg
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            // Control signals
            mem_reg_write  <= 1'b0;
            mem_mem_read   <= 1'b0;
            mem_mem_write  <= 1'b0;
            mem_mem_to_reg <= 1'b0;
            // Data
            mem_alu_result <= 16'b0;
            mem_write_data <= 16'b0;
            mem_write_reg  <= 3'b0;
        end
        else begin
            // Control signals
            mem_reg_write  <= ex_reg_write;
            mem_mem_read   <= ex_mem_read;
            mem_mem_write  <= ex_mem_write;
            mem_mem_to_reg <= ex_mem_to_reg;
            // Data
            mem_alu_result <= ex_alu_result;
            mem_write_data <= ex_reg2_data;
            mem_write_reg  <= ex_write_reg;
        end
    end

endmodule