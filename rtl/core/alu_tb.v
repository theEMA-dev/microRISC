`include "../defines.v"
`timescale 1ns/1ps

module alu_tb;
    // Test signals
    reg  [15:0] a, b;
    reg  [3:0]  alu_op;
    wire [15:0] result;
    wire        zero;
    
    // Test vector structure
    reg [15:0] expected_result;
    reg expected_zero;
    integer errors;
    
    // Instantiate ALU
    alu dut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero(zero)
    );

    // Test vectors
    initial begin
        errors = 0;
        
        // Test ADD
        test_alu(`ALU_ADD, 16'd5, 16'd3, 16'd8, 1'b0, "ADD");
        test_alu(`ALU_ADD, 16'd65535, 16'd1, 16'd0, 1'b1, "ADD overflow");
        
        // Test SUB
        test_alu(`ALU_SUB, 16'd5, 16'd3, 16'd2, 1'b0, "SUB");
        test_alu(`ALU_SUB, 16'd3, 16'd3, 16'd0, 1'b1, "SUB equal");
        
        // Test AND
        test_alu(`ALU_AND, 16'hFF00, 16'h0F0F, 16'h0F00, 1'b0, "AND");
        
        // Test OR
        test_alu(`ALU_OR, 16'hFF00, 16'h0F0F, 16'hFF0F, 1'b0, "OR");
        
        // Test SLT
        test_alu(`ALU_SLT, 16'd5, 16'd10, 16'd1, 1'b0, "SLT true");
        test_alu(`ALU_SLT, 16'd10, 16'd5, 16'd0, 1'b1, "SLT false");
        
        // Test SLL
        test_alu(`ALU_SLL, 16'd2, 16'h1, 16'h4, 1'b0, "SLL");
        
        // Test SRL
        test_alu(`ALU_SRL, 16'd2, 16'h8, 16'h2, 1'b0, "SRL");

        // Report results
        $display("\nTest completed with %d errors", errors);
        $finish;
    end

    // Test execution task
    task test_alu;
        input [3:0] op;
        input [15:0] in_a;
        input [15:0] in_b;
        input [15:0] exp_result;
        input exp_zero;
        input [24*8:1] test_name;
        
        begin
            a = in_a;
            b = in_b;
            alu_op = op;
            expected_result = exp_result;
            expected_zero = exp_zero;
            
            #1; // Wait for combinational logic
            
            if (result !== expected_result || zero !== expected_zero) begin
                $display("Error in %s:", test_name);
                $display("  Inputs: a=%h, b=%h, op=%h", a, b, alu_op);
                $display("  Expected: result=%h, zero=%b", expected_result, expected_zero);
                $display("  Got:      result=%h, zero=%b", result, zero);
                errors = errors + 1;
            end else begin
                $display("%s: OK", test_name);
            end
        end
    endtask

    // Generate waveforms
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end

endmodule