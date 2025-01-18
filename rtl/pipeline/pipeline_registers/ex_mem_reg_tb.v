`include "../../defines.v"
`timescale 1ns/1ps

module ex_mem_reg_tb;
    // Clock and control
    reg         clk;
    reg         rst_n;
    reg         flush;
    
    // Input signals (EX stage)
    reg         ex_reg_write;
    reg         ex_mem_read;
    reg         ex_mem_write;
    reg         ex_mem_to_reg;
    reg  [15:0] ex_alu_result;
    reg  [15:0] ex_reg2_data;
    reg  [2:0]  ex_write_reg;
    
    // Output signals (MEM stage)
    wire        mem_reg_write;
    wire        mem_mem_read;
    wire        mem_mem_write;
    wire        mem_mem_to_reg;
    wire [15:0] mem_alu_result;
    wire [15:0] mem_write_data;
    wire [2:0]  mem_write_reg;

    // Test tracking
    integer errors;

    // DUT instantiation
    ex_mem_reg dut (.*);

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        $dumpfile("ex_mem_reg_tb.vcd");
        $dumpvars(0, ex_mem_reg_tb);
        
        // Initialize
        errors = 0;
        initialize_signals();
        
        // Test 1: Reset
        test_reset();
        
        // Test 2: Normal operation
        test_normal_operation();
        
        // Test 3: Flush
        test_flush();
        
        // Report and finish
        $display("\nTest completed with %d errors", errors);
        $finish;
    end

    // Tasks
    task initialize_signals;
        begin
            rst_n = 1;
            flush = 0;
            ex_reg_write = 0;
            ex_mem_read = 0;
            ex_mem_write = 0;
            ex_mem_to_reg = 0;
            ex_alu_result = 16'h0000;
            ex_reg2_data = 16'h0000;
            ex_write_reg = 3'b000;
        end
    endtask

    task test_reset;
        begin
            $display("\nTesting reset...");
            rst_n = 0;
            @(posedge clk);
            #1 verify_reset_state();
            rst_n = 1;
            @(posedge clk);
        end
    endtask

    task test_normal_operation;
        begin
            $display("\nTesting normal operation...");
            ex_reg_write = 1;
            ex_mem_read = 1;
            ex_alu_result = 16'hABCD;
            ex_reg2_data = 16'h1234;
            ex_write_reg = 3'b101;
            
            @(posedge clk);
            #1 verify_normal_operation();
        end
    endtask

    task test_flush;
        begin
            $display("\nTesting flush...");
            flush = 1;
            @(posedge clk);
            #1 verify_reset_state();
            flush = 0;
        end
    endtask

    task verify_reset_state;
        begin
            if (mem_reg_write !== 0 || mem_mem_read !== 0 || 
                mem_mem_write !== 0 || mem_mem_to_reg !== 0 || 
                mem_alu_result !== 16'h0000 || 
                mem_write_data !== 16'h0000 || 
                mem_write_reg !== 3'b000) begin
                $display("Error: Reset state verification failed");
                errors = errors + 1;
            end
        end
    endtask

    task verify_normal_operation;
        begin
            if (mem_reg_write !== ex_reg_write || 
                mem_mem_read !== ex_mem_read ||
                mem_alu_result !== ex_alu_result ||
                mem_write_data !== ex_reg2_data ||
                mem_write_reg !== ex_write_reg) begin
                $display("Error: Normal operation verification failed");
                errors = errors + 1;
            end
        end
    endtask

endmodule