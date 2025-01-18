`include "../defines.v"

module id_stage (
    input  wire        clk,
    input  wire        rst_n,
    // Pipeline control
    input  wire        stall,
    input  wire        flush,
    // Instruction input
    input  wire [15:0] instruction,
    input  wire [15:0] pc,
    // Register write-back
    input  wire        wb_reg_write,
    input  wire [2:0]  wb_write_reg,
    input  wire [15:0] wb_write_data,
    // Outputs
    output wire [2:0]  rs,
    output wire [2:0]  rt,
    output wire [2:0]  rd,
    output wire [5:0]  immediate,
    output wire [15:0] reg1_data,
    output wire [15:0] reg2_data,
    // Control signals
    output wire        reg_write,
    output wire        mem_read,
    output wire        mem_write,
    output wire        mem_to_reg,
    output wire        alu_src,
    output wire [3:0]  alu_op,
    output wire [1:0]  reg_dst,
    output wire        branch,
    output wire        branch_ne,
    output wire        jump,
    output wire        jump_reg,
    output wire        link
);

    wire [3:0] opcode;
    wire [2:0] funct;
    
    // Instruction decoder instance
    instruction_decoder decoder (
        .instruction(instruction),
        .opcode(opcode),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .funct(funct),
        .immediate(immediate)
    );
    
    // Control unit instance
    control_unit ctrl_unit (
        .opcode(opcode),
        .funct(funct),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .reg_dst(reg_dst),
        .branch(branch),
        .branch_ne(branch_ne),
        .jump(jump),
        .jump_reg(jump_reg),
        .link(link)
    );
    
    // Register file instance
    register_file reg_file (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_addr(rs),
        .rs2_addr(rt),
        .rs1_data(reg1_data),
        .rs2_data(reg2_data),
        .we(wb_reg_write),
        .rd_addr(wb_write_reg),
        .rd_data(wb_write_data)
    );

endmodule