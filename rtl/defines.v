// Global parameters and definitions
`ifndef DEFINES_V
`define DEFINES_V

// Basic parameters
`define WORD_SIZE       16  // 16-bit processor
`define REG_ADDR_WIDTH  3   // 8 registers (R0-R7)
`define MEM_ADDR_WIDTH  9   // 512 bytes = 2^9

// Instruction field widths
`define OPCODE_WIDTH    4
`define FUNC_WIDTH      3
`define REG_ADDR_WIDTH  3
`define IMM_WIDTH       6
`define J_ADDR_WIDTH    12

// Instruction field positions
`define OPCODE_POS      12  // [15:12]
`define RS_POS          9   // [11:9]
`define RT_POS          6   // [8:6]
`define RD_POS          3   // [5:3]
`define FUNC_POS        0   // [2:0]
`define IMM_POS         0   // [5:0]
`define J_ADDR_POS      0   // [11:0]

// Opcodes
`define OP_R_TYPE   4'b0000  // R-type instructions
`define OP_ADDI     4'b0001  // Add immediate
`define OP_LW       4'b0010  // Load word
`define OP_SW       4'b0011  // Store word
`define OP_BEQ      4'b0100  // Branch if equal
`define OP_BNE      4'b0101  // Branch if not equal
`define OP_J        4'b1100  // Jump
`define OP_JAL      4'b1101  // Jump and link
`define OP_JR       4'b1110  // Jump register

// Function codes for R-type instructions
`define FUNC_ADD    3'b000
`define FUNC_SUB    3'b001
`define FUNC_AND    3'b010
`define FUNC_OR     3'b011
`define FUNC_SLT    3'b100
`define FUNC_SLL    3'b101
`define FUNC_SRL    3'b110

// ALU Operations
`define ALU_ADD  4'b0000
`define ALU_SUB  4'b0001
`define ALU_AND  4'b0010
`define ALU_OR   4'b0011
`define ALU_SLT  4'b0100
`define ALU_SLL  4'b0101
`define ALU_SRL  4'b0110

// Instruction Types
`define R_TYPE 2'b00
`define I_TYPE 2'b01
`define J_TYPE 2'b10

`endif