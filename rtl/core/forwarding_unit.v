`include "../defines.v"

module forwarding_unit (
    // Input addresses
    input  wire [2:0]  id_ex_rs,
    input  wire [2:0]  id_ex_rt,
    // EX/MEM signals
    input  wire        ex_mem_reg_write,
    input  wire [2:0]  ex_mem_write_reg,
    // MEM/WB signals
    input  wire        mem_wb_reg_write,
    input  wire [2:0]  mem_wb_write_reg,
    // Forwarding control signals
    output reg  [1:0]  forward_a,  // For RS data
    output reg  [1:0]  forward_b   // For RT data
);

    always @(*) begin
        // Default: no forwarding
        forward_a = 2'b00;
        forward_b = 2'b00;
        
        // EX hazard
        if (ex_mem_reg_write && (ex_mem_write_reg != 0) && 
            (ex_mem_write_reg == id_ex_rs)) begin
            forward_a = 2'b01;
        end
        
        if (ex_mem_reg_write && (ex_mem_write_reg != 0) && 
            (ex_mem_write_reg == id_ex_rt)) begin
            forward_b = 2'b01;
        end
        
        // MEM hazard
        if (mem_wb_reg_write && (mem_wb_write_reg != 0) && 
            !(ex_mem_reg_write && (ex_mem_write_reg != 0) && 
              (ex_mem_write_reg == id_ex_rs)) &&
            (mem_wb_write_reg == id_ex_rs)) begin
            forward_a = 2'b10;
        end
        
        if (mem_wb_reg_write && (mem_wb_write_reg != 0) && 
            !(ex_mem_reg_write && (ex_mem_write_reg != 0) && 
              (ex_mem_write_reg == id_ex_rt)) &&
            (mem_wb_write_reg == id_ex_rt)) begin
            forward_b = 2'b10;
        end
    end

endmodule