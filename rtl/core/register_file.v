`include "../defines.v"

module register_file (
    input  wire        clk,
    input  wire        rst_n,
    // Read ports
    input  wire [2:0]  rs1_addr,    // Source register 1 address
    input  wire [2:0]  rs2_addr,    // Source register 2 address
    output wire [15:0] rs1_data,    // Source register 1 data
    output wire [15:0] rs2_data,    // Source register 2 data
    // Write port
    input  wire        we,          // Write enable
    input  wire [2:0]  rd_addr,     // Destination register address
    input  wire [15:0] rd_data      // Data to write
);

    // Register file (8 registers x 16 bits)
    reg [15:0] registers[0:7];
    integer i;

    // Asynchronous read
    assign rs1_data = (rs1_addr == 0) ? 16'b0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 0) ? 16'b0 : registers[rs2_addr];

    // Synchronous write
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers to 0
            for (i = 0; i < 8; i = i + 1) begin
                registers[i] <= 16'b0;
            end
        end
        else if (we && rd_addr != 0) begin // R0 is hardwired to 0
            registers[rd_addr] <= rd_data;
        end
    end

endmodule