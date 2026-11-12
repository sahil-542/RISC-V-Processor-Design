`timescale 1ns / 1ps

`include "definitions.vh"

module controlunit(
    input  wire [6:0] opcode,   // instruction[6:0]
    input  wire [2:0] funct3,   // instruction[14:12]
    input  wire  funct7_5,   // instruction[31:25]
    input [31:0] id_instr,rs1_data,rs2_data,
    output reg        reg_write,
    output reg        mem_read, // 1: from memory to reg; 0: ALU/JAL/LUI
    output reg        mem_write,
    output reg        alu_src,    // 1: immediate / mem addr, 0: register
    output reg        branch,     // branch instruction bit
    output reg        jump,       // jump instruction bit
    output reg        jumpr,     
    output reg [3:0]  alu_ctrl,    // ALU operation code (see mapping below)
    output reg [1:0]  wb_sel,   // 0: ALU result, 1: memory data, 2: PC+4 (for JAL/JALR)
    output reg [4 : 0] rs1_e, rs2_e, rd_e,
    output reg auipc
);

    // funct3 is used to differentiate among different types of opcode
    //funct7 provides further distinction within funct3 as to what operation is used


    always @(*) begin
        // default values
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        alu_src    = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        wb_sel     = 2'b00; // default to ALU result
        alu_ctrl   = `OP_ALU_ADD; // default ADD operation is considered
        auipc = 1'b0;
        jumpr = 1'b0;
        case (opcode)
            `OPC_RTYPE: begin
                // R-type: register-register arithmetic
                reg_write = 1'b1;
                rs1_e = id_instr[19:15];
                rs2_e = id_instr[24:20];
                rd_e = id_instr[11:7];
                jump = 1'b0;
                // decode by funct3/funct7
                case (funct3)
                    3'b000: alu_ctrl = funct7_5 ? `OP_ALU_SUB : `OP_ALU_ADD; // SUB/ADD
                    3'b001: alu_ctrl = `OP_ALU_SLL; // SLL
                    3'b010: alu_ctrl = `OP_ALU_SLT; // SLT
                    3'b011: alu_ctrl = `OP_ALU_SLTU; // SLTU
                    3'b100: alu_ctrl = `OP_ALU_XOR; // XOR
                    3'b101: alu_ctrl = funct7_5 ? `OP_ALU_SRA : `OP_ALU_SRL; // SRA/SRL
                    3'b110: alu_ctrl = `OP_ALU_OR; // OR
                    3'b111: alu_ctrl = `OP_ALU_AND; // AND
                    default: alu_ctrl = `OP_ALU_ADD;
                endcase
            end

            `OPC_ITYPE: begin
                // I-type ALU immediate (ADDI, SLLI, SLTI, etc.)
                reg_write  = 1'b1;
                alu_src    = 1'b1;  // immediate
                rs1_e = id_instr[19:15];
                rs2_e = 5'b0;
                rd_e = id_instr[11:7];
                jump = 1'b0;
                case (funct3)
                    3'b000: alu_ctrl = `OP_ALU_ADD; // ADDI
                    3'b001: alu_ctrl = `OP_ALU_SLL; // SLLI
                    3'b010: alu_ctrl = `OP_ALU_SLT; // SLTI
                    3'b011: alu_ctrl = `OP_ALU_SLTU; // SLTIU
                    3'b100: alu_ctrl = `OP_ALU_XOR; // XORI
                    3'b101: alu_ctrl = funct7_5 ? `OP_ALU_SRA : `OP_ALU_SRL; // SRAI/SRLI (funct7 bit 30 or 0)
                    3'b110: alu_ctrl = `OP_ALU_OR; // ORI
                    3'b111: alu_ctrl = `OP_ALU_AND; // ANDI
                    default: alu_ctrl = `OP_ALU_ADD;
                endcase
                auipc = 1'b0;
            end

            `OPC_LOAD: begin
                // Loads: ALU computes address, then read memory
                wb_sel     = 2'b01; // memory data
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                alu_src    = 1'b1; // immediate offset
                rs1_e = id_instr[19:15];
                rs2_e = 5'b0;
                rd_e = id_instr[11:7];
                jump = 1'b0;
            end

            `OPC_STORE: begin
                // Stores: ALU computes address, then write memory
                mem_write  = 1'b1;
                alu_src    = 1'b1;
                rs1_e = id_instr[19:15];
                rs2_e = id_instr[24:20];
                rd_e = 5'b0;
                jump = 1'b0;                
            end

             `OPC_BRANCH: begin
                // Branches: ALU used for compare; typical implementation:
                // BEQ/BNE -> SUB (zero test)
                // BLT/BGE -> SLT
                // BLTU/BGEU -> SLTU
                branch = 1'b1;
                alu_src= 1'b0; // compare registers
                rs1_e = id_instr[19:15];
                rs2_e = id_instr[24:20];
                rd_e = 5'b0;
                case (funct3)
                    `BRANCH_BEQ: alu_ctrl = `OP_ALU_SUB; // BEQ use SUB==0
                    `BRANCH_BNE: alu_ctrl = `OP_ALU_SUB; // BNE also SUB
                    `BRANCH_BLT: alu_ctrl = `OP_ALU_SLT; // BLT -> SLT
                    `BRANCH_BGE: alu_ctrl = `OP_ALU_SLT; // BGE -> SLT (check sign)
                    `BRANCH_BLTU: alu_ctrl = `OP_ALU_SLTU; // BLTU -> SLTU
                    `BRANCH_BGEU: alu_ctrl = `OP_ALU_SLTU; // BGEU -> SLTU
                    default: alu_ctrl = `OP_ALU_SUB;
                endcase
                auipc = 1'b0;
                jump = 1'b0;                
                // branch statements are mapped to shift left instructions in order to introduce offset to PC 
            end

            `OPC_JAL: begin
                // JAL: write PC+4 to rd, jump
                wb_sel     = 2'b10; // PC+4
                reg_write  = 1'b1;
                jump       = 1'b1;
                rs1_e = 5'b0;
                rs2_e = 5'b0;
                rd_e = id_instr[11:7];                
            end

            `OPC_JALR: begin
                wb_sel     = 2'b10; // PC+4
                reg_write  = (id_instr[11:7] != 0);
                jump       = 1'b0;
                jumpr       = 1'b1;
                alu_src    = 1'b1;
                rs1_e      = id_instr[19:15]; // rs1
                rs2_e      = 5'b0;
                rd_e       = id_instr[11:7];
            end

            `OPC_LUI: begin
                // LUI: load upper immediate into rd (no ALU op needed)
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                alu_ctrl   = `OP_ALU_PASS; // PASS for direct output
                rs1_e = 5'b0;
                rs2_e = 5'b0;
                rd_e = id_instr[11:7];
                jump = 1'b0;

            end

            `OPC_AUIPC: begin
                // AUIPC: rd = PC + immediate
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                rs1_e = 5'b0;
                rs2_e = 5'b0;
                rd_e = id_instr[11:7];
                auipc = 1'b1;
                jump = 1'b0;
                
            end

            default: begin
                // unrecognized opcode: keep defaults (no writes)
                rd_e = 5'b0;
                rs1_e = 5'b0;
                rs2_e = 5'b0;
                jumpr = 1'b0;
                jump = 1'b0;
                
            end
        endcase
//        if(opcode[6]&~opcode[2]) begin 
//            {rs2_e,rs1_e} = {id_instr[24:15]};
//            case (funct3[2:1]) // branch instruction
//                    2'b00:  branch = (rs1_data == rs2_data)^funct3[0];               
//                    2'b10:  branch = ($signed(rs1_data) <  $signed(rs2_data))^funct3[0];
//                    2'b11: branch = ($unsigned(rs1_data) <  $unsigned(rs2_data))^funct3[0];                  
//                    default:      branch = 1'b0;
//                endcase
//        end
    end

endmodule