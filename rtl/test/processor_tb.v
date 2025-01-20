`timescale 1ns/1ps
`include "../defines.v"

module processor_tb;
    reg         clk;
    reg         rst_n;
    wire [15:0] debug_pc;
    wire [15:0] debug_instruction;
    wire [15:0] debug_reg_write_data;
    wire [2:0]  debug_reg_write_addr;
    wire        debug_reg_write_enable;
    reg [15:0] ex1_memory [0:3];

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Load program
        $readmemh("test_program.hex", processor.if_stage_inst.imem.imem);
        
        // Enable waveform dump
        $dumpfile("processor.vcd");
        $dumpvars(0, processor_tb);
        
        // Reset sequence
        rst_n = 0;
        @(posedge clk);
        @(posedge clk);
        rst_n = 1;
        
        // Run program
        repeat(100) @(posedge clk);
        
        $display("Simulation completed");
        $finish;
    end

    // Monitor pipeline stages
    always @(posedge clk) begin
        if (rst_n) begin
            $display("\nTime=%0t", $time);
            $display("IF: PC=%h Inst=%h", debug_pc, debug_instruction);
            if (debug_reg_write_enable)
                $display("WB: Writing R%0d = %h", 
                    debug_reg_write_addr, debug_reg_write_data);
        end
    end

        // Add hazard monitoring
    always @(posedge clk) begin
        if (rst_n) begin
            $display("Time=%0t PC=%h Inst=%h Stall=%b Flush=%b",
                $time, debug_pc, debug_instruction, 
                processor.hazard_detection_inst.stall,
                processor.hazard_detection_inst.flush);
        end
    end

    // Processor instantiation
    processor_top processor (
        .clk(clk),
        .rst_n(rst_n),
        .debug_pc(debug_pc),
        .debug_instruction(debug_instruction),
        .debug_reg_write_data(debug_reg_write_data),
        .debug_reg_write_addr(debug_reg_write_addr),
        .debug_reg_write_enable(debug_reg_write_enable)
    );

endmodule