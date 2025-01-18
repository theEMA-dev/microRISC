`include "../../defines.v"

module id_ex_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        flush,
    // Control signals
    input  wire        id_reg_write,
    input  wire        id_mem_read,
    input  wire        id_mem_write,
    input  wire        id_mem_to_reg,
    input  wire        id_alu_src,
    input  wire [3:0]  id_alu_op,
    input  wire [1:0]  id_reg_dst,
    // Register data
    input  wire [15:0] id_pc,
    input  wire [15:0] id_reg1_data,
    input  wire [15:0] id_reg2_data,
    input  wire [2:0]  id_rs,
    input  wire [2:0]  id_rt,
    input  wire [2:0]  id_rd,
    input  wire [5:0]  id_imm,
    // Outputs to EX stage
    output reg         ex_reg_write,
    output reg         ex_mem_read,
    output reg         ex_mem_write,
    output reg         ex_mem_to_reg,
    output reg         ex_alu_src,
    output reg  [3:0]  ex_alu_op,
    output reg  [1:0]  ex_reg_dst,
    output reg  [15:0] ex_pc,
    output reg  [15:0] ex_reg1_data,
    output reg  [15:0] ex_reg2_data,
    output reg  [2:0]  ex_rs,
    output reg  [2:0]  ex_rt,
    output reg  [2:0]  ex_rd,
    output reg  [5:0]  ex_imm
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            // Control signals
            ex_reg_write  <= 1'b0;
            ex_mem_read   <= 1'b0;
            ex_mem_write  <= 1'b0;
            ex_mem_to_reg <= 1'b0;
            ex_alu_src    <= 1'b0;
            ex_alu_op     <= 4'b0;
            ex_reg_dst    <= 2'b0;
            // Data
            ex_pc         <= 16'b0;
            ex_reg1_data  <= 16'b0;
            ex_reg2_data  <= 16'b0;
            ex_rs         <= 3'b0;
            ex_rt         <= 3'b0;
            ex_rd         <= 3'b0;
            ex_imm        <= 6'b0;
        end
        else begin
            // Control signals
            ex_reg_write  <= id_reg_write;
            ex_mem_read   <= id_mem_read;
            ex_mem_write  <= id_mem_write;
            ex_mem_to_reg <= id_mem_to_reg;
            ex_alu_src    <= id_alu_src;
            ex_alu_op     <= id_alu_op;
            ex_reg_dst    <= id_reg_dst;
            // Data
            ex_pc         <= id_pc;
            ex_reg1_data  <= id_reg1_data;
            ex_reg2_data  <= id_reg2_data;
            ex_rs         <= id_rs;
            ex_rt         <= id_rt;
            ex_rd         <= id_rd;
            ex_imm        <= id_imm;
        end
    end

endmodule