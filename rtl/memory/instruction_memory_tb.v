`include "../defines.v"
`timescale 1ns/1ps

module instruction_memory_tb;
    reg  [8:0]  addr;
    wire [15:0] inst;
    
    // Test storage
    reg [15:0] test_program [0:3];
    integer i, errors;
    
    // Instantiate instruction memory
    instruction_memory dut (
        .addr(addr),
        .inst(inst)
    );

    initial begin
        // Initialize test program
        test_program[0] = 16'h1234;
        test_program[1] = 16'h5678; 
        test_program[2] = 16'h9ABC;
        test_program[3] = 16'hDEF0;
        
        // Create hex file
        write_hex_file();
        
        // Initialize
        addr = 0;
        errors = 0;
        
        // Wait for memory initialization
        #10;

        // Test word-aligned reads
        for (i = 0; i < 4; i = i + 1) begin
            addr = i << 1; // Word aligned addresses
            #2;
            verify_instruction(addr, test_program[i]);
        end

        // Test unaligned access
        test_unaligned_access();
        
        // Report results
        $display("\nTest completed with %0d errors", errors);
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("instruction_memory_tb.vcd");
        $dumpvars(0, instruction_memory_tb);
    end

    // Task to write hex file
    task write_hex_file;
        integer fd;
        begin
            fd = $fopen("instruction.hex", "w");
            if (fd) begin
                $fdisplay(fd, "%h", test_program[0]);
                $fdisplay(fd, "%h", test_program[1]);
                $fdisplay(fd, "%h", test_program[2]);
                $fdisplay(fd, "%h", test_program[3]);
                $fclose(fd);
            end else begin
                $display("Error: Could not create instruction.hex file");
                $finish;
            end
        end
    endtask

    // Task to verify instruction read
    task verify_instruction;
        input [8:0] check_addr;
        input [15:0] expected;
        begin
            if (inst !== expected) begin
                $display("Error at addr %h: expected %h, got %h", 
                        check_addr, expected, inst);
                errors = errors + 1;
            end else begin
                $display("Address %h: OK", check_addr);
            end
        end
    endtask

    // Task to test unaligned access
    task test_unaligned_access;
        begin
            addr = 9'h001; // Unaligned address
            #2;
            if (inst !== test_program[0]) begin
                $display("Error: Unaligned access at %h failed", addr);
                errors = errors + 1;
            end
        end
    endtask

endmodule