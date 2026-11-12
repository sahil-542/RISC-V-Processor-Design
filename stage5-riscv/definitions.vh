`ifndef DEFINITIONS_VH
`define DEFINITIONS_VH

// Width definitions
`define DATA_WIDTH 32   // Data width in bits
`define ADDR_WIDTH 5   // Address width in bits
`define INST_WIDTH 32
`define NUM_REGISTER 32

`define FUNCT_7 7

// RISC-V Base Instruction Set Opcodes
`define OPCODE 7
`define OPC_RTYPE   7'b0110011 // ALU Instructions (ADD, SUB, AND, OR, XOR, etc.)
`define OPC_ITYPE   7'b0010011 // ALU Immediate Instructions (ADDI, ANDI, ORI...)
`define OPC_LOAD    7'b0000011 // Load Instructions (LB, LH, LW, LBU, LHU)
`define OPC_STORE   7'b0100011 // Store Instructions (SB, SH, SW)
`define OPC_BRANCH  7'b1100011 // Branch Instructions (BEQ, BNE, BLT, etc.)
`define OPC_JAL     7'b1101111 // Jump and Link
`define OPC_JALR    7'b1100111 // Jump and Link Register
`define OPC_LUI     7'b0110111 // Load Upper Immediate
`define OPC_AUIPC   7'b0010111 // Add Upper Immediate to PC

`define OP_FENCE   7'b0001111 // Fence
`define OP_SYSTEM  7'b1110011 // System Instructions (ECALL, EBREAK, etc.)

// RISC-V ALU Operations
`define OP_ALU_ADD    4'b0000 // Add
`define OP_ALU_SUB    4'b0001 // Subtract
`define OP_ALU_SLL    4'b0010 // Shift Left Logical
`define OP_ALU_SLT    4'b0011 // Set Less Than (signed)
`define OP_ALU_SLTU   4'b0100 // Set Less Than (unsigned)
`define OP_ALU_XOR    4'b0101 // Bitwise XOR
`define OP_ALU_SRL    4'b0110 // Shift Right Logical
`define OP_ALU_SRA    4'b0111 // Shift Right Arithmetic
`define OP_ALU_OR     4'b1000 // Bitwise OR
`define OP_ALU_AND    4'b1001 // Bitwise AND
`define OP_ALU_PASS    4'b1111 

`define BRANCH_BEQ    3'b000 // Branch Equal
`define BRANCH_BNE    3'b001 // Branch Not Equal
`define BRANCH_BLT    3'b100 // Branch Less Than
`define BRANCH_BGE    3'b101 // Branch Greater Than Or Equal
`define BRANCH_BLTU    3'b110 // Branch Less Than Unsigned
`define BRANCH_BGEU    3'b111 // Branch Greater Than Or Equal Unsigned

// `define BRANCH_JAL_JALR 3'b010

`endif
