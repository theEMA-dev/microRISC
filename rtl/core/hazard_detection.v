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
    output wire        stall,
    output wire        flush
);

    // Load-use hazard detection
    wire load_use_hazard;
    assign load_use_hazard = id_ex_mem_read && 
                            ((id_ex_rt == id_rs) || (id_ex_rt == id_rt));
    
    // Control hazard detection
    wire control_hazard;
    assign control_hazard = branch_taken || jump || jump_reg;
    
    // Stall on load-use hazard
    assign stall = load_use_hazard;
    
    // Flush on control hazards
    assign flush = control_hazard;

endmodule