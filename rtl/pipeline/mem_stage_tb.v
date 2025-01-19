module mem_stage_tb();
    reg         clk;
    reg         rst_n;
    reg         mem_read;
    reg         mem_write;
    reg  [15:0] alu_result;
    reg  [15:0] write_data;
    wire [15:0] read_data;
    wire [15:0] mem_alu_result;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Instantiate MEM stage
    mem_stage uut (
        .clk(clk),
        .rst_n(rst_n),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_result(alu_result),
        .write_data(write_data),
        .read_data(read_data),
        .mem_alu_result(mem_alu_result)
    );

    // Test stimulus
    initial begin
        // Initialize signals
        rst_n = 0;
        mem_read = 0;
        mem_write = 0;
        alu_result = 16'h0000;
        write_data = 16'h0000;

        // Wait for reset
        #100;
        rst_n = 1;

        // Test memory write
        mem_write = 1;
        alu_result = 16'h0004;
        write_data = 16'hABCD;
        #10;

        // Test memory read
        mem_write = 0;
        mem_read = 1;
        #10;
        if (read_data !== 16'hABCD)
            $display("Error: Memory read/write failed");

        // Test ALU result passthrough
        if (mem_alu_result !== alu_result)
            $display("Error: ALU result passthrough failed");

        $display("MEM Stage testbench completed");
        $finish;
    end
endmodule