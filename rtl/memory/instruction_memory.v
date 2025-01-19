`include "../defines.v"

module instruction_memory (
    input  wire [8:0]  addr,     // 9-bit address for 512 bytes
    output wire [15:0] inst      // 16-bit instruction output
);

    // 512 bytes organized as 256 x 16-bit memory
    reg [15:0] imem [0:255];
    integer i;
    
    // Read is asynchronous for instruction memory
    assign inst = imem[addr[8:1]]; // Convert byte address to word address
    
    // Initialize memory
    initial begin
        // First initialize all memory to 0
        for (i = 0; i < 256; i = i + 1) begin
            imem[i] = 16'h0000;
        end
        
        // Then load program
        $readmemh("D:/Dev/microRISC/rtl/memory/instruction.hex", imem, 0, 3);
    end

endmodule