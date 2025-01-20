`include "../defines.v"

module instruction_memory (
    input  wire [8:0]  addr,     // Word address (no shift needed)
    output wire [15:0] inst      // 16-bit instruction output
);

    reg [15:0] imem [0:255];    // Word-addressed memory
    
    // Direct word addressing
    assign inst = imem[addr];    // Removed shift since addr is now word address
    
    // Memory initialization removed - will be done by testbench

endmodule