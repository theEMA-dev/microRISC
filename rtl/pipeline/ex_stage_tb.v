`include "../defines.v"
`timescale 1ns/1ps

module ex_stage_tb;
    // Test signals
    reg  [3:0]  alu_op;
    reg         alu_src;
    reg  [15:0] reg1_data;
    reg  [15:0] reg2_data;
    reg  [5:0]  immediate;
    reg  [2:0]  rd;
    reg  [2:0]  rt;
    reg  [1:0]  reg_dst;
    reg  [1:0]  forward_a;
    reg  [1:0]  forward_b;
    reg  [15:0] mem_forward_data;
    reg  [15:0] wb_forward_data;
    
    wire [15:0] alu_result;
    wire        zero_flag;
    wire [2:0]  write_reg_addr;
    
    integer errors;

    // DUT instantiation
    ex_stage dut (.*);

    initial begin
        errors = 0;
        initialize_signals();
        
        // Test sequence
        test_basic_alu_ops();
        test_forwarding();
        test_reg_dst_selection();
        test_immediate_handling();
        
        $display("\nTest completed with %d errors", errors);
        $finish;
    end

    task initialize_signals;
        begin
            alu_op = 0;
            alu_src = 0;
            reg1_data = 0;
            reg2_data = 0;
            immediate = 0;
            rd = 0;
            rt = 0;
            reg_dst = 0;
            forward_a = 0;
            forward_b = 0;
            mem_forward_data = 0;
            wb_forward_data = 0;
        end
    endtask

    task test_basic_alu_ops;
        begin
            $display("\nTesting basic ALU operations...");
            
            // Test ADD
            alu_op = `ALU_ADD;
            reg1_data = 16'h0005;
            reg2_data = 16'h0003;
            alu_src = 0;
            #1;
            if (alu_result !== 16'h0008)
                report_error("ADD", 16'h0008, alu_result);
                
            // Test SUB
            alu_op = `ALU_SUB;
            #1;
            if (alu_result !== 16'h0002)
                report_error("SUB", 16'h0002, alu_result);
                
            // Test Zero flag
            reg1_data = 16'h0005;
            reg2_data = 16'h0005;
            #1;
            if (!zero_flag)
                $display("Error: Zero flag not set when result is zero");
        end
    endtask

    task test_forwarding;
        begin
            $display("\nTesting forwarding...");
            
            // Test MEM forwarding
            forward_a = 2'b01;
            mem_forward_data = 16'h00A0;
            reg2_data = 16'h0010;
            alu_op = `ALU_ADD;
            #1;
            if (alu_result !== 16'h00B0)
                report_error("MEM forwarding", 16'h00B0, alu_result);
                
            // Test WB forwarding
            forward_b = 2'b10;
            wb_forward_data = 16'h0020;
            #1;
            if (alu_result !== 16'h00C0)
                report_error("WB forwarding", 16'h00C0, alu_result);
        end
    endtask

    task test_reg_dst_selection;
        begin
            $display("\nTesting register destination selection...");
            
            // Test rd selection
            reg_dst = 2'b00;
            rd = 3'b010;
            rt = 3'b011;
            #1;
            if (write_reg_addr !== 3'b010)
                report_error("RD selection", 3'b010, write_reg_addr);
                
            // Test rt selection
            reg_dst = 2'b01;
            #1;
            if (write_reg_addr !== 3'b011)
                report_error("RT selection", 3'b011, write_reg_addr);
                
            // Test JAL selection
            reg_dst = 2'b10;
            #1;
            if (write_reg_addr !== 3'b111)
                report_error("JAL selection", 3'b111, write_reg_addr);
        end
    endtask

    task test_immediate_handling;
        begin
            $display("\nTesting immediate handling...");
            
            // Test positive immediate
            alu_src = 1;
            immediate = 6'b000101; // 5
            reg1_data = 16'h0003;
            reg2_data = 16'h0000;  // Should be ignored
            forward_a = 2'b00;     // Use reg1_data
            forward_b = 2'b00;     // Use reg2_data
            alu_op = `ALU_ADD;
            #1;
            if (alu_result !== 16'h0008)
                report_error("Immediate", 16'h0008, alu_result);
                
            // Test negative immediate
            immediate = 6'b111111; // -1 (sign extended)
            #1;
            if (alu_result !== 16'h0002)
                report_error("Sign extended immediate", 16'h0002, alu_result);
        end
    endtask

    task report_error;
        input [24*8:1] test_name;
        input [15:0] expected;
        input [15:0] actual;
        begin
            $display("Error in %s: Expected %h, got %h", test_name, expected, actual);
            errors = errors + 1;
        end
    endtask

endmodule