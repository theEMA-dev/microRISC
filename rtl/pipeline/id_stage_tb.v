`include "../defines.v"
`timescale 1ns/1ps

module id_stage_tb();
    reg         clk;
    reg         rst_n;
    reg         stall;
    reg         flush;
    reg  [15:0] instruction;
    reg  [15:0] pc;
    reg         wb_reg_write;
    reg  [2:0]  wb_write_reg;
    reg  [15:0] wb_write_data;

    wire [2:0]  rs;
    wire [2:0]  rt;
    wire [2:0]  rd;
    wire [5:0]  immediate;
    wire [15:0] reg1_data;
    wire [15:0] reg2_data;
    wire        reg_write;
    wire        mem_read;
    wire        mem_write;
    wire        mem_to_reg;
    wire        alu_src;
    wire [3:0]  alu_op;
    wire [1:0]  reg_dst;
    wire        branch;
    wire        branch_ne;
    wire        jump;
    wire        jump_reg;
    wire        link;

    // Instance of ID stage
    id_stage uut (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .flush(flush),
        .instruction(instruction),
        .pc(pc),
        .wb_reg_write(wb_reg_write),
        .wb_write_reg(wb_write_reg),
        .wb_write_data(wb_write_data),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .immediate(immediate),
        .reg1_data(reg1_data),
        .reg2_data(reg2_data),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .reg_dst(reg_dst),
        .branch(branch),
        .branch_ne(branch_ne),
        .jump(jump),
        .jump_reg(jump_reg),
        .link(link)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize
        rst_n = 0;
        stall = 0;
        flush = 0;
        instruction = 16'h0000;
        pc = 16'h0000;
        wb_reg_write = 0;
        wb_write_reg = 0;
        wb_write_data = 0;

        // Release reset
        #10 rst_n = 1;

        // Test R-type instruction (add r1, r2, r3)
        #10 instruction = 16'b0000_001_010_011_000;
        #10;
        if (alu_op !== 4'b0000) $display("Error: ADD decode failed");

        // Test I-type instruction (addi r2, r3, 5)
        #10 instruction = 16'b0001_011_010_000101;
        #10;
        if (alu_src !== 1'b1) $display("Error: ADDI decode failed");

        // Test load instruction (lw r4, 8(r2))
        #10 instruction = 16'b0010_010_100_001000;
        #10;
        if (mem_read !== 1'b1) $display("Error: LW decode failed");

        // Test register writeback
        wb_reg_write = 1;
        wb_write_reg = 3'b001;
        wb_write_data = 16'hABCD;
        #10;

        $display("ID Stage Testbench Complete");
        #100 $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t instruction=%h reg_write=%b mem_read=%b mem_write=%b",
                 $time, instruction, reg_write, mem_read, mem_write);
    end
endmodule