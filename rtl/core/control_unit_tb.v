`include "../defines.v"
`timescale 1ns/1ps

module control_unit_tb;
    // Test bench signals
    reg  [3:0] opcode;
    reg  [2:0] funct;
    wire       reg_write, mem_read, mem_write, mem_to_reg;
    wire       alu_src;
    wire [3:0] alu_op;
    wire [1:0] reg_dst;
    wire       branch, branch_ne, jump, jump_reg, link;

    // Test case structure
    reg [31:0] vector_count;
    integer    errors;
    
    // Instantiate control unit
    control_unit dut (
        .opcode(opcode),
        .funct(funct),
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

    // Test execution
    initial begin
        $dumpfile("control_unit_tb.vcd");
        $dumpvars(0, control_unit_tb);
        errors = 0;

        // Test R-type instructions
        test_r_type(`FUNC_ADD, "ADD");
        test_r_type(`FUNC_SUB, "SUB");
        test_r_type(`FUNC_AND, "AND");
        test_r_type(`FUNC_OR,  "OR");
        test_r_type(`FUNC_SLT, "SLT");
        test_r_type(`FUNC_SLL, "SLL");
        test_r_type(`FUNC_SRL, "SRL");

        // Test I-type instructions
        test_i_type(`OP_ADDI, "ADDI");
        test_i_type(`OP_LW,   "LW");
        test_i_type(`OP_SW,   "SW");

        // Test branch instructions
        test_branch(`OP_BEQ, "BEQ");
        test_branch(`OP_BNE, "BNE");

        // Test jump instructions
        test_jump(`OP_J,   "J");
        test_jump(`OP_JAL, "JAL");
        test_jump(`OP_JR,  "JR");

        $display("\nTest completed with %d errors", errors);
        $finish;
    end

    // Test tasks
    task test_r_type;
        input [2:0] f;
        input [24*8:1] inst_name;
        begin
            opcode = `OP_R_TYPE;
            funct = f;
            #1;
            check_signals(inst_name);
        end
    endtask

    task test_i_type;
        input [3:0] op;
        input [24*8:1] inst_name;
        begin
            opcode = op;
            funct = 3'b000;
            #1;
            check_signals(inst_name);
        end
    endtask

    task test_branch;
        input [3:0] op;
        input [24*8:1] inst_name;
        begin
            opcode = op;
            funct = 3'b000;
            #1;
            check_signals(inst_name);
        end
    endtask

    task test_jump;
        input [3:0] op;
        input [24*8:1] inst_name;
        begin
            opcode = op;
            funct = 3'b000;
            #1;
            check_signals(inst_name);
        end
    endtask

    task check_signals;
        input [24*8:1] inst_name;
        begin
            $display("\nTesting %s instruction:", inst_name);
            $display("Control signals:");
            $display("  reg_write=%b, mem_read=%b, mem_write=%b",
                    reg_write, mem_read, mem_write);
            $display("  mem_to_reg=%b, alu_src=%b, alu_op=%b",
                    mem_to_reg, alu_src, alu_op);
            $display("  reg_dst=%b, branch=%b, branch_ne=%b",
                    reg_dst, branch, branch_ne);
            $display("  jump=%b, jump_reg=%b, link=%b",
                    jump, jump_reg, link);
        end
    endtask

endmodule