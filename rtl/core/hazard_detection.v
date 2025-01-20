`include "../defines.v"

module hazard_detection (
    // Inputs from ID stage
    input  wire [2:0]  id_rs,
    input  wire [2:0]  id_rt,
    // Inputs from ID/EX pipeline register
    input  wire [2:0]  id_ex_rt,
    input  wire        id_ex_mem_read,
    // Branch and jump signals
    input  wire        branch_taken,
    input  wire        jump,
    input  wire        jump_reg,
    // Output control signals
    output reg         stall,
    output reg         flush
);

    // Load-use hazard detection
    wire load_use_hazard;
    assign load_use_hazard = id_ex_mem_read && 
                            ((id_ex_rt == id_rs) || (id_ex_rt == id_rt));
    
    // Control hazard detection
    wire control_hazard;
    assign control_hazard = branch_taken || jump || jump_reg;
    
    // Priority encoder for hazards
    always @(*) begin
        if (load_use_hazard) begin
            stall = 1'b1;
            flush = 1'b0;
        end
        else if (control_hazard) begin
            stall = 1'b0;
            flush = 1'b1;
        end
        else begin
            stall = 1'b0;
            flush = 1'b0;
        end
    end

endmodule