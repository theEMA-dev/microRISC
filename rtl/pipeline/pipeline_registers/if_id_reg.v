`include "../../defines.v"

module if_id_reg (
    input  wire        clk,
    input  wire        rst_n,
    // Pipeline control
    input  wire        stall,     // Stall signal from hazard unit
    input  wire        flush,     // Flush signal from control unit
    // IF stage inputs
    input  wire [15:0] if_pc,
    input  wire [15:0] if_inst,
    // ID stage outputs
    output reg  [15:0] id_pc,
    output reg  [15:0] id_inst
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_pc   <= 16'b0;
            id_inst <= 16'b0;
        end
        else if (flush) begin
            id_pc   <= 16'b0;
            id_inst <= 16'b0;
        end
        else if (!stall) begin
            id_pc   <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule