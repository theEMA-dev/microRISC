`include "../../defines.v"
`timescale 1ns/1ps

module mem_wb_reg_tb;
    // Clock and control
    reg         clk;
    reg         rst_n;
    reg         flush;
    
    // MEM stage signals
    reg         mem_reg_write;
    reg         mem_mem_to_reg;
    reg  [15:0] mem_alu_result;
    reg  [15:0] mem_read_data;
    reg  [2:0]  mem_write_reg;
    
    // WB stage signals
    wire        wb_reg_write;
    wire        wb_mem_to_reg;
    wire [15:0] wb_alu_result;
    wire [15:0] wb_read_data;
    wire [2:0]  wb_write_reg;
    
    integer errors;

    // DUT instantiation
    mem_wb_reg dut (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush),
        .mem_reg_write(mem_reg_write),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_alu_result(mem_alu_result),
        .mem_read_data(mem_read_data),
        .mem_write_reg(mem_write_reg),
        .wb_reg_write(wb_reg_write),
        .wb_mem_to_reg(wb_mem_to_reg),
        .wb_alu_result(wb_alu_result),
        .wb_read_data(wb_read_data),
        .wb_write_reg(wb_write_reg)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        $dumpfile("mem_wb_reg_tb.vcd");
        $dumpvars(0, mem_wb_reg_tb);
        
        errors = 0;
        initialize_signals();
        
        // Test sequence
        test_reset();
        test_normal_operation();
        test_flush();
        
        $display("\nTest completed with %d errors", errors);
        $finish;
    end

    // Tasks
    task initialize_signals;
        begin
            rst_n = 1;
            flush = 0;
            mem_reg_write = 0;
            mem_mem_to_reg = 0;
            mem_alu_result = 16'h0000;
            mem_read_data = 16'h0000;
            mem_write_reg = 3'b000;
        end
    endtask

    task test_reset;
        begin
            $display("\nTesting reset...");
            @(posedge clk);
            rst_n = 0;
            #1 verify_reset_state();
            rst_n = 1;
        end
    endtask

    task test_normal_operation;
        begin
            $display("\nTesting normal operation...");
            @(posedge clk);
            mem_reg_write = 1;
            mem_mem_to_reg = 1;
            mem_alu_result = 16'hABCD;
            mem_read_data = 16'h1234;
            mem_write_reg = 3'b101;
            
            @(posedge clk);
            #1 verify_normal_operation();
        end
    endtask

    task test_flush;
        begin
            $display("\nTesting flush...");
            @(posedge clk);
            flush = 1;
            #1 verify_reset_state();
            flush = 0;
        end
    endtask

    task verify_reset_state;
        begin
            if (wb_reg_write !== 0 || wb_mem_to_reg !== 0 ||
                wb_alu_result !== 16'h0000 || wb_read_data !== 16'h0000 ||
                wb_write_reg !== 3'b000) begin
                $display("Error: Reset state verification failed");
                errors = errors + 1;
            end
        end
    endtask

    task verify_normal_operation;
        begin
            if (wb_reg_write !== mem_reg_write || 
                wb_mem_to_reg !== mem_mem_to_reg ||
                wb_alu_result !== mem_alu_result ||
                wb_read_data !== mem_read_data ||
                wb_write_reg !== mem_write_reg) begin
                $display("Error: Normal operation verification failed");
                errors = errors + 1;
            end
        end
    endtask

endmodule