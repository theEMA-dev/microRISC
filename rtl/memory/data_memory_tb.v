`include "../defines.v"
`timescale 1ns/1ps

module data_memory_tb;
    reg         clk;
    reg         rst_n;
    reg         mem_read;
    reg         mem_write;
    reg  [8:0]  addr;
    reg  [15:0] write_data;
    wire [15:0] read_data;

    data_memory dut (
        .clk(clk),
        .rst_n(rst_n),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 1;
        mem_read = 0;
        mem_write = 0;
        addr = 0;
        write_data = 0;

        // Test 1: Reset
        #10 rst_n = 0;
        #10 rst_n = 1;

        // Test 2: Write and Read
        #10 begin
            mem_write = 1;
            addr = 9'h002;
            write_data = 16'hABCD;
        end
        
        #10 begin
            mem_write = 0;
            mem_read = 1;
            #1 if (read_data !== 16'hABCD)
                $display("Error: read %h expected %h", read_data, 16'hABCD);
        end

        // Test 3: Write Multiple
        #10 begin
            mem_read = 0;
            mem_write = 1;
            addr = 9'h004;
            write_data = 16'h1234;
        end
        
        #10 begin
            addr = 9'h006;
            write_data = 16'h5678;
        end

        // Test 4: Read Multiple
        #10 begin
            mem_write = 0;
            mem_read = 1;
            addr = 9'h004;
            #1 if (read_data !== 16'h1234)
                $display("Error at addr 4");
        end

        #10 begin
            addr = 9'h006;
            #1 if (read_data !== 16'h5678)
                $display("Error at addr 6");
        end

        #10 $finish;
    end

endmodule