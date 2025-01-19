`include "../defines.v"

module processor_top (
    input  wire        clk,
    input  wire        rst_n,
    // Debug/Test outputs
    output wire [15:0] debug_pc,
    output wire [15:0] debug_instruction,
    output wire [15:0] debug_reg_write_data,
    output wire [2:0]  debug_reg_write_addr,
    output wire        debug_reg_write_enable
);

    // Pipeline stage outputs
    // IF stage
    wire [15:0] if_pc;
    wire [15:0] if_instruction;
    wire [15:0] if_next_pc;

    // ID stage
    wire [15:0] id_pc;
    wire [15:0] id_instruction;
    wire [15:0] id_reg1_data;
    wire [15:0] id_reg2_data;
    wire [2:0]  id_rs;
    wire [2:0]  id_rt;
    wire [2:0]  id_rd;
    wire [5:0]  id_immediate;
    wire        id_reg_write;
    wire        id_mem_read;
    wire        id_mem_write;
    wire        id_mem_to_reg;
    wire        id_alu_src;
    wire [3:0]  id_alu_op;
    wire [1:0]  id_reg_dst;
    wire        id_branch;
    wire        id_branch_ne;
    wire        id_jump;
    wire        id_jump_reg;
    wire        id_link;

    // EX stage
    wire [15:0] ex_pc;
    wire [15:0] ex_reg1_data;
    wire [15:0] ex_reg2_data;
    wire [15:0] ex_alu_result;
    wire        ex_zero_flag;
    wire [2:0]  ex_write_reg_addr;
    wire        ex_reg_write;
    wire        ex_mem_read;
    wire        ex_mem_write;
    wire        ex_mem_to_reg;
    wire [3:0]  ex_alu_op;      
    wire [1:0]  ex_reg_dst;     
    wire [2:0]  ex_rs;            
    wire [2:0]  ex_rt;          
    wire [2:0]  ex_rd;          
    wire [5:0]  ex_imm;         
    wire [15:0] wb_alu_result;  
    wire [15:0] wb_read_data;   

    // MEM stage
    wire [15:0] mem_alu_result;
    wire [15:0] mem_write_data;
    wire [15:0] mem_read_data;
    wire [2:0]  mem_write_reg;
    wire        mem_reg_write;
    wire        mem_mem_to_reg;
    wire        mem_mem_read;
    wire        mem_mem_write;

    // WB stage
    wire [15:0] wb_write_data;
    wire [2:0]  wb_write_reg;
    wire        wb_reg_write;
    wire        wb_mem_to_reg;

    // Hazard and forwarding control signals
    wire        stall;
    wire        flush;
    wire [1:0]  forward_a;
    wire [1:0]  forward_b;

    // Branch and jump control
    wire        branch_taken;
    wire [15:0] branch_target;
    wire [15:0] jump_target;
    wire [15:0] jr_target;

    // Debug outputs
    assign debug_pc = if_pc;
    assign debug_instruction = if_instruction;
    assign debug_reg_write_data = wb_write_data;
    assign debug_reg_write_addr = wb_write_reg;
    assign debug_reg_write_enable = wb_reg_write;

    // Module instantiations
    // IF Stage
    if_stage if_stage_inst (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .branch_taken(branch_taken),
        .jump(id_jump),
        .jump_reg(id_jump_reg),
        .branch_target(branch_target),
        .jump_target(jump_target),
        .jr_target(jr_target),
        .pc(if_pc),
        .next_pc(if_next_pc),
        .instruction(if_instruction)
    );
    
    // IF/ID Pipeline Register
    if_id_reg if_id_reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .flush(flush),
        .if_pc(if_pc),
        .if_inst(if_instruction),
        .id_pc(id_pc),
        .id_inst(id_instruction)
    );
    
    // ID Stage
    id_stage id_stage_inst (
        .clk(clk),
        .rst_n(rst_n),
        .instruction(id_instruction),
        .pc(id_pc),
        .wb_reg_write(wb_reg_write),
        .wb_write_reg(wb_write_reg),
        .wb_write_data(wb_write_data),
        .rs(id_rs),
        .rt(id_rt),
        .rd(id_rd),
        .immediate(id_immediate),
        .reg1_data(id_reg1_data),
        .reg2_data(id_reg2_data),
        .reg_write(id_reg_write),
        .mem_read(id_mem_read),
        .mem_write(id_mem_write),
        .mem_to_reg(id_mem_to_reg),
        .alu_src(id_alu_src),
        .alu_op(id_alu_op),
        .reg_dst(id_reg_dst),
        .branch(id_branch),
        .branch_ne(id_branch_ne),
        .jump(id_jump),
        .jump_reg(id_jump_reg),
        .link(id_link)
    );
    
    // ID/EX Pipeline Register
    id_ex_reg id_ex_reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush),
        .id_reg_write(id_reg_write),
        .id_mem_read(id_mem_read),
        .id_mem_write(id_mem_write),
        .id_mem_to_reg(id_mem_to_reg),
        .id_alu_src(id_alu_src),
        .id_alu_op(id_alu_op),
        .id_reg_dst(id_reg_dst),
        .id_pc(id_pc),
        .id_reg1_data(id_reg1_data),
        .id_reg2_data(id_reg2_data),
        .id_rs(id_rs),
        .id_rt(id_rt),
        .id_rd(id_rd),
        .id_imm(id_immediate),
        .ex_reg_write(ex_reg_write),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_alu_src(ex_alu_src),
        .ex_alu_op(ex_alu_op),
        .ex_reg_dst(ex_reg_dst),
        .ex_pc(ex_pc),
        .ex_reg1_data(ex_reg1_data),
        .ex_reg2_data(ex_reg2_data),
        .ex_rs(ex_rs),
        .ex_rt(ex_rt),
        .ex_rd(ex_rd),
        .ex_imm(ex_imm)
    );
    
    // EX Stage
    ex_stage ex_stage_inst (
        .alu_op(ex_alu_op),
        .alu_src(ex_alu_src),
        .reg1_data(ex_reg1_data),
        .reg2_data(ex_reg2_data),
        .immediate(ex_imm),
        .rd(ex_rd),
        .rt(ex_rt),
        .reg_dst(ex_reg_dst),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .mem_forward_data(mem_alu_result),
        .wb_forward_data(wb_write_data),
        .alu_result(ex_alu_result),
        .zero_flag(ex_zero_flag),
        .write_reg_addr(ex_write_reg_addr)
    );
    
    // EX/MEM Pipeline Register
    ex_mem_reg ex_mem_reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush),
        .ex_reg_write(ex_reg_write),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_alu_result(ex_alu_result),
        .ex_reg2_data(ex_reg2_data),
        .ex_write_reg(ex_write_reg_addr),
        .mem_reg_write(mem_reg_write),
        .mem_mem_read(mem_mem_read),
        .mem_mem_write(mem_mem_write),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_alu_result(mem_alu_result),
        .mem_write_data(mem_write_data),
        .mem_write_reg(mem_write_reg)
    );
    
    // MEM Stage
    mem_stage mem_stage_inst (
        .clk(clk),
        .rst_n(rst_n),
        .mem_read(mem_mem_read),
        .mem_write(mem_mem_write),
        .alu_result(mem_alu_result),
        .write_data(mem_write_data),
        .read_data(mem_read_data),
        .mem_alu_result(mem_alu_result)
    );
    
    // MEM/WB Pipeline Register
    mem_wb_reg mem_wb_reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush),
        .mem_reg_write(mem_reg_write),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_alu_result(mem_alu_result),
        .mem_read_data(mem_read_data),
        .mem_write_reg(mem_write_reg),
        .wb_reg_write(wb_reg_write),
        .wb_mem_to_reg(wb_mem_to_reg),
        .wb_alu_result(wb_alu_result),
        .wb_read_data(wb_read_data),
        .wb_write_reg(wb_write_reg)
    );
    
    // WB Stage
    wb_stage wb_stage_inst (
        .mem_to_reg(wb_mem_to_reg),
        .mem_read_data(wb_read_data),
        .alu_result(wb_alu_result),
        .write_back_data(wb_write_data)
    );
    
    // Hazard Detection Unit
    hazard_detection hazard_detection_inst (
        .id_rs(id_rs),
        .id_rt(id_rt),
        .id_ex_rt(ex_rt),
        .id_ex_mem_read(ex_mem_read),
        .branch_taken(branch_taken),
        .jump(id_jump),
        .jump_reg(id_jump_reg),
        .stall(stall),
        .flush(flush)
    );
    
    // Forwarding Unit
    forwarding_unit forwarding_unit_inst (
        .id_ex_rs(ex_rs),
        .id_ex_rt(ex_rt),
        .ex_mem_reg_write(mem_reg_write),
        .ex_mem_write_reg(mem_write_reg),
        .mem_wb_reg_write(wb_reg_write),
        .mem_wb_write_reg(wb_write_reg),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

endmodule