`include "../defines.v"
`timescale 1ns/1ps

module if_stage_tb;
    // Signals
    reg         clk;
    reg         rst_n;
    reg         stall;
    reg         branch_taken;
    reg         jump;
    reg         jump_reg;
    reg  [15:0] branch_target;
    reg  [15:0] jump_target;
    reg  [15:0] jr_target;
    wire [15:0] pc;
    wire [15:0] next_pc;
    wire [15:0] instruction;

    // Test control
    integer errors;

    // DUT instantiation
    if_stage dut (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .branch_taken(branch_taken),
        .jump(jump),
        .jump_reg(jump_reg),
        .branch_target(branch_target),
        .jump_target(jump_target),
        .jr_target(jr_target),
        .pc(pc),
        .next_pc(next_pc),
        .instruction(instruction)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        $dumpfile("if_stage_tb.vcd");
        $dumpvars(0, if_stage_tb);
        
        errors = 0;
        initialize_signals();
        
        // Test sequence
        test_reset();
        test_sequential_fetch();
        test_branch();
        test_jump();
        test_jump_register();
        test_stall();
        
        // End simulation
        $display("\nTest completed with %d errors", errors);
        $finish;
    end

    // Tasks
    task initialize_signals;
        begin
            rst_n = 1;
            stall = 0;
            branch_taken = 0;
            jump = 0;
            jump_reg = 0;
            branch_target = 16'h0000;
            jump_target = 16'h0000;
            jr_target = 16'h0000;
        end
    endtask

    task test_reset;
        begin
            $display("\nTesting reset...");
            rst_n = 0;
            @(posedge clk);
            #1 if (pc !== 16'h0000) begin
                $display("Error: Reset failed. PC = %h", pc);
                errors = errors + 1;
            end
            rst_n = 1;
        end
    endtask

    task test_sequential_fetch;
        begin
            $display("\nTesting sequential fetch...");
            @(posedge clk);
            #1 if (next_pc !== (pc + 16'd2)) begin
                $display("Error: Sequential fetch failed");
                errors = errors + 1;
            end
        end
    endtask

    task test_branch;
        begin
            $display("\nTesting branch...");
            branch_target = 16'h0100;
            branch_taken = 1;
            @(posedge clk);
            #1 if (pc !== 16'h0100) begin
                $display("Error: Branch failed. PC = %h", pc);
                errors = errors + 1;
            end
            branch_taken = 0;
        end
    endtask

    task test_jump;
        begin
            $display("\nTesting jump...");
            jump_target = 16'h0200;
            jump = 1;
            @(posedge clk);
            #1 if (pc !== 16'h0200) begin
                $display("Error: Jump failed. PC = %h", pc);
                errors = errors + 1;
            end
            jump = 0;
        end
    endtask

    task test_jump_register;
        begin
            $display("\nTesting jump register...");
            jr_target = 16'h0300;
            jump_reg = 1;
            @(posedge clk);
            #1 if (pc !== 16'h0300) begin
                $display("Error: Jump register failed. PC = %h", pc);
                errors = errors + 1;
            end
            jump_reg = 0;
        end
    endtask

    task test_stall;
        begin
            $display("\nTesting stall...");
            stall = 1;
            @(posedge clk);
            #1 if (pc !== 16'h0300) begin
                $display("Error: Stall failed. PC changed during stall");
                errors = errors + 1;
            end
            stall = 0;
        end
    endtask

endmodule