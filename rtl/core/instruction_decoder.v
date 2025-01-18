`include "../defines.v"

module instruction_decoder (
    input  wire [15:0] instruction,        // 16-bit instruction input
    
    // Decoded instruction fields
    output wire [3:0]  opcode,            // 4-bit opcode
    output wire [2:0]  rs,                // 3-bit source register 1
    output wire [2:0]  rt,                // 3-bit source register 2
    output wire [2:0]  rd,                // 3-bit destination register
    output wire [2:0]  funct,             // 3-bit function code
    output wire [5:0]  immediate,         // 6-bit immediate
    output wire [11:0] jump_target,       // 12-bit jump target
    
    // Instruction type flags
    output wire        is_r_type,
    output wire        is_i_type,
    output wire        is_j_type
);

    // Extract instruction fields based on your format
    assign opcode = instruction[`OPCODE_POS +: `OPCODE_WIDTH];
    assign rs = instruction[`RS_POS +: `REG_ADDR_WIDTH];
    assign rt = instruction[`RT_POS +: `REG_ADDR_WIDTH];
    assign rd = instruction[`RD_POS +: `REG_ADDR_WIDTH];
    assign funct = instruction[`FUNC_POS +: `FUNC_WIDTH];
    assign immediate = instruction[`IMM_POS +: `IMM_WIDTH];
    assign jump_target = instruction[`J_ADDR_POS +: `J_ADDR_WIDTH];

    // Determine instruction type based on opcode
    assign is_r_type = (opcode == `OP_R_TYPE);
    assign is_j_type = (opcode == `OP_J) || (opcode == `OP_JAL) || (opcode == `OP_JR);
    assign is_i_type = !(is_r_type || is_j_type);

endmodule