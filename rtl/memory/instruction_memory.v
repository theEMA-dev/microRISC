`include "../defines.v"

module instruction_memory (
    input  wire [8:0]  addr,     // 9-bit address for 512 bytes
    output wire [15:0] inst      // 16-bit instruction output
);

    // 512 bytes organized as 256 x 16-bit memory
    reg [15:0] imem [0:255];
    
    // Read is asynchronous for instruction memory
    assign inst = imem[addr[8:1]]; // Convert byte address to word address
    
    // Initialize memory - typically done through testbench
    // or external file in real implementation
    initial begin
        $readmemh("instruction.hex", imem);
    end

endmodule