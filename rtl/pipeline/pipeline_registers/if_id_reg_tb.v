`include "../../defines.v"
`timescale 1ns/1ps

module if_id_reg_tb;
    // Signals
    reg         clk;
    reg         rst_n;
    reg         stall;
    reg         flush;
    reg  [15:0] if_pc;
    reg  [15:0] if_inst;
    wire [15:0] id_pc;
    wire [15:0] id_inst;
    
    // Error tracking
    integer errors;

    // DUT instantiation
    if_id_reg dut (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .flush(flush),
        .if_pc(if_pc),
        .if_inst(if_inst),
        .id_pc(id_pc),
        .id_inst(id_inst)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize
        errors = 0;
        rst_n = 1;
        stall = 0;
        flush = 0;
        if_pc = 16'h0000;
        if_inst = 16'h0000;

        // Test 1: Reset
        #10 rst_n = 0;
        #10 rst_n = 1;

        // Test 2: Normal operation
        #10 begin
            if_pc = 16'h1234;
            if_inst = 16'h5678;
        end

        // Test 3: Stall
        #20 stall = 1;
        #10 begin
            if_pc = 16'h9ABC;
            if_inst = 16'hDEF0;
        end
        #10 stall = 0;

        // Test 4: Flush
        #10 begin
            if_pc = 16'h4321;
            if_inst = 16'h8765;
            flush = 1;
        end
        #10 flush = 0;

        // End simulation
        #20 $finish;
    end

    // Monitor changes
    always @(posedge clk) begin
        $display("Time=%0t rst_n=%b stall=%b flush=%b", $time, rst_n, stall, flush);
        $display("IF: pc=%h inst=%h", if_pc, if_inst);
        $display("ID: pc=%h inst=%h\n", id_pc, id_inst);
    end

endmodule