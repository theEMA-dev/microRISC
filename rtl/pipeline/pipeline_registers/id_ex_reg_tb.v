`include "../../defines.v"
`timescale 1ns/1ps

module id_ex_reg_tb;
    // Clock and control
    reg         clk;
    reg         rst_n;
    reg         flush;
    
    // Input control signals
    reg         id_reg_write;
    reg         id_mem_read;
    reg         id_mem_write;
    reg         id_mem_to_reg;
    reg         id_alu_src;
    reg  [3:0]  id_alu_op;
    reg  [1:0]  id_reg_dst;
    
    // Input data signals
    reg  [15:0] id_pc;
    reg  [15:0] id_reg1_data;
    reg  [15:0] id_reg2_data;
    reg  [2:0]  id_rs;
    reg  [2:0]  id_rt;
    reg  [2:0]  id_rd;
    reg  [5:0]  id_imm;
    
    // Output signals
    wire        ex_reg_write;
    wire        ex_mem_read;
    wire        ex_mem_write;
    wire        ex_mem_to_reg;
    wire        ex_alu_src;
    wire [3:0]  ex_alu_op;
    wire [1:0]  ex_reg_dst;
    wire [15:0] ex_pc;
    wire [15:0] ex_reg1_data;
    wire [15:0] ex_reg2_data;
    wire [2:0]  ex_rs;
    wire [2:0]  ex_rt;
    wire [2:0]  ex_rd;
    wire [5:0]  ex_imm;

    // Test tracking
    integer errors;

    // DUT instantiation
    id_ex_reg dut (.*);

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize
        errors = 0;
        initialize_signals();
        
        // Test 1: Reset
        test_reset();
        
        // Test 2: Normal operation
        test_normal_operation();
        
        // Test 3: Flush
        test_flush();
        
        // End simulation
        $display("\nTest completed with %d errors", errors);
        $finish;
    end

    // Tasks
    task initialize_signals;
        begin
            rst_n = 1;
            flush = 0;
            id_reg_write = 0;
            id_mem_read = 0;
            id_mem_write = 0;
            id_mem_to_reg = 0;
            id_alu_src = 0;
            id_alu_op = 0;
            id_reg_dst = 0;
            id_pc = 0;
            id_reg1_data = 0;
            id_reg2_data = 0;
            id_rs = 0;
            id_rt = 0;
            id_rd = 0;
            id_imm = 0;
        end
    endtask

    task test_reset;
        begin
            rst_n = 0;
            @(posedge clk);
            #1 check_reset_values();
            rst_n = 1;
            @(posedge clk);
        end
    endtask

    task test_normal_operation;
        begin
            // Set test values
            id_reg_write = 1;
            id_mem_read = 1;
            id_alu_op = 4'b0101;
            id_pc = 16'h1234;
            id_reg1_data = 16'hABCD;
            id_rs = 3'b101;
            
            @(posedge clk);
            #1 check_normal_propagation();
        end
    endtask

    task test_flush;
        begin
            flush = 1;
            @(posedge clk);
            #1 check_reset_values();
            flush = 0;
        end
    endtask

    task check_reset_values;
        begin
            if (ex_reg_write !== 0 || ex_mem_read !== 0 || 
                ex_mem_write !== 0 || ex_pc !== 16'h0) begin
                $display("Reset check failed");
                errors = errors + 1;
            end
        end
    endtask

    task check_normal_propagation;
        begin
            if (ex_reg_write !== id_reg_write || 
                ex_mem_read !== id_mem_read ||
                ex_pc !== id_pc ||
                ex_reg1_data !== id_reg1_data) begin
                $display("Normal propagation check failed");
                errors = errors + 1;
            end
        end
    endtask

endmodule