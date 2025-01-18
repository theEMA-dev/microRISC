`include "../defines.v"

module data_memory (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [8:0]  addr,
    input  wire [15:0] write_data,
    output wire [15:0] read_data
);

    reg [15:0] dmem [0:255];
    integer i;  // Moved declaration to module level
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 256; i = i + 1) begin
                dmem[i] <= 16'b0;
            end
        end
        else if (mem_write) begin
            dmem[addr[8:1]] <= write_data;
        end
    end
    
    assign read_data = mem_read ? dmem[addr[8:1]] : 16'b0;

endmodule