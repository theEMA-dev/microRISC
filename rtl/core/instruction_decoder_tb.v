`include "../defines.v"
`timescale 1ns/1ps

module instruction_decoder_tb;
    // Testbench signals
    reg  [15:0] instruction;
    wire [3:0]  opcode;
    wire [2:0]  rs, rt, rd, funct;
    wire [5:0]  immediate;
    wire [11:0] jump_target;
    wire        is_r_type, is_i_type, is_j_type;

    // Instantiate the instruction decoder
    instruction_decoder decoder (
        .instruction(instruction),
        .opcode(opcode),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .funct(funct),
        .immediate(immediate),
        .jump_target(jump_target),
        .is_r_type(is_r_type),
        .is_i_type(is_i_type),
        .is_j_type(is_j_type)
    );

    // Test cases
    initial begin
        $dumpfile("instruction_decoder_tb.vcd");
        $dumpvars(0, instruction_decoder_tb);
        
        // Test R-type instruction (add r1, r2, r3)
        #10 instruction = 16'b0000_001_010_011_000;
        #1 check_r_type("ADD");

        // Test I-type instruction (addi r2, r3, 5)
        #10 instruction = 16'b0001_011_010_000101;
        #1 check_i_type("ADDI");

        // Test branch instruction (beq r1, r2, 4)
        #10 instruction = 16'b0100_001_010_000100;
        #1 check_i_type("BEQ");

        // Test jump instruction (j 0x100)
        #10 instruction = 16'b1100_000100000000;
        #1 check_j_type("J");

        #10 $finish;
    end

    // Task to check R-type instruction decoding
    task check_r_type;
        input [7:0] instr_name;
        begin
            $display("Testing %s instruction:", instr_name);
            $display("opcode=%b rs=%b rt=%b rd=%b funct=%b", 
                    opcode, rs, rt, rd, funct);
            if (!is_r_type) 
                $display("Error: instruction not detected as R-type");
        end
    endtask

    // Task to check I-type instruction decoding
    task check_i_type;
        input [7:0] instr_name;
        begin
            $display("Testing %s instruction:", instr_name);
            $display("opcode=%b rs=%b rt=%b immediate=%b", 
                    opcode, rs, rt, immediate);
            if (!is_i_type) 
                $display("Error: instruction not detected as I-type");
        end
    endtask

    // Task to check J-type instruction decoding
    task check_j_type;
        input [7:0] instr_name;
        begin
            $display("Testing %s instruction:", instr_name);
            $display("opcode=%b jump_target=%b", opcode, jump_target);
            if (!is_j_type) 
                $display("Error: instruction not detected as J-type");
        end
    endtask

endmodule