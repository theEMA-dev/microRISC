`include "../defines.v"

module ex_stage (
    // Inputs from ID/EX pipeline register
    input  wire [3:0]  alu_op,
    input  wire        alu_src,
    input  wire [15:0] reg1_data,
    input  wire [15:0] reg2_data,
    input  wire [5:0]  immediate,
    input  wire [2:0]  rd,
    input  wire [2:0]  rt,
    input  wire [1:0]  reg_dst,
    // Forwarding inputs
    input  wire [1:0]  forward_a,
    input  wire [1:0]  forward_b,
    input  wire [15:0] mem_forward_data,
    input  wire [15:0] wb_forward_data,
    // Outputs
    output wire [15:0] alu_result,
    output wire        zero_flag,
    output wire [2:0]  write_reg_addr
);

    wire [15:0] alu_input_a;
    wire [15:0] alu_input_b;
    wire [15:0] reg2_data_mux;
    
    // Forwarding mux for input A
    always @(*) begin
        case (forward_a)
            2'b00: alu_input_a = reg1_data;
            2'b01: alu_input_a = mem_forward_data;
            2'b10: alu_input_a = wb_forward_data;
            default: alu_input_a = reg1_data;
        endcase
    end
    
    // Forwarding mux for input B
    always @(*) begin
        case (forward_b)
            2'b00: reg2_data_mux = reg2_data;
            2'b01: reg2_data_mux = mem_forward_data;
            2'b10: reg2_data_mux = wb_forward_data;
            default: reg2_data_mux = reg2_data;
        endcase
    end
    
    // ALU source B mux
    assign alu_input_b = alu_src ? {{10{immediate[5]}}, immediate} : reg2_data_mux;
    
    // ALU instance
    alu alu_unit (
        .a(alu_input_a),
        .b(alu_input_b),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(zero_flag)
    );
    
    // Write register mux
    assign write_reg_addr = (reg_dst == 2'b00) ? rd :
                           (reg_dst == 2'b01) ? rt :
                           3'b111; // R7 for JAL

endmodule