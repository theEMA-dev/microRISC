`include "../defines.v"
`timescale 1ns/1ps

module if_stage_tb();
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

    // Instance of IF stage
    if_stage uut (
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
        // Initialize
        initialize_signals();
        
        // Test reset
        test_reset();
        
        // Test sequential execution
        test_sequential();
        
        // Test control flow
        test_branch();
        test_jump();
        test_jump_register();
        
        // Test stall
        test_stall();

        $display("IF Stage Testbench Complete");
        #100 $finish;
    end

    task initialize_signals;
        begin
            rst_n = 0;
            stall = 0;
            branch_taken = 0;
            jump = 0;
            jump_reg = 0;
            branch_target = 16'h0020;
            jump_target = 16'h0030;
            jr_target = 16'h0040;
        end
    endtask

    task test_reset;
        begin
            @(posedge clk);
            rst_n = 0;
            @(posedge clk);
            if (pc !== 16'h0000) 
                $display("Error: Reset failed, pc = %h", pc);
            rst_n = 1;
        end
    endtask

    task test_sequential;
        begin
            @(posedge clk);
            if (pc !== 16'h0002) 
                $display("Error: First increment failed, pc = %h", pc);
            @(posedge clk);
            if (pc !== 16'h0004) 
                $display("Error: Second increment failed, pc = %h", pc);
        end
    endtask

    task test_branch;
        begin
            branch_taken = 1;
            @(posedge clk);
            if (pc !== branch_target)
                $display("Error: Branch failed, pc = %h", pc);
            branch_taken = 0;
            @(posedge clk);
        end
    endtask

    task test_jump;
        begin
            jump = 1;
            @(posedge clk);
            if (pc !== jump_target)
                $display("Error: Jump failed, pc = %h", pc);
            jump = 0;
            @(posedge clk);
        end
    endtask

    task test_jump_register;
        begin
            jump_reg = 1;
            @(posedge clk);
            if (pc !== jr_target)
                $display("Error: Jump register failed, pc = %h", pc);
            jump_reg = 0;
            @(posedge clk);
        end
    endtask

    task test_stall;
        begin
            stall = 1;
            @(posedge clk);
            if (pc !== pc)
                $display("Error: Stall failed, pc = %h", pc);
            stall = 0;
            @(posedge clk);
        end
    endtask

    // Monitor changes
    initial begin
        $monitor("Time=%0t rst_n=%b stall=%b branch=%b jump=%b jr=%b pc=%h",
                 $time, rst_n, stall, branch_taken, jump, jump_reg, pc);
    end
endmodule