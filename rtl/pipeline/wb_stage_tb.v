module wb_stage_tb();
    reg         mem_to_reg;
    reg  [15:0] mem_read_data;
    reg  [15:0] alu_result;
    wire [15:0] write_back_data;

    // Instantiate WB stage
    wb_stage uut (
        .mem_to_reg(mem_to_reg),
        .mem_read_data(mem_read_data),
        .alu_result(alu_result),
        .write_back_data(write_back_data)
    );

    // Test stimulus
    initial begin
        // Initialize inputs
        mem_to_reg = 0;
        mem_read_data = 16'hABCD;
        alu_result = 16'h1234;

        // Test ALU result selection
        #10;
        if (write_back_data !== 16'h1234)
            $display("Error: ALU result selection failed");

        // Test memory data selection
        mem_to_reg = 1;
        #10;
        if (write_back_data !== 16'hABCD)
            $display("Error: Memory data selection failed");

        $display("WB Stage testbench completed");
        $finish;
    end
endmodule