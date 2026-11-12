`timescale 1ns / 1ps

`include "definitions.vh"

module sign_ext(
input wire [`INST_WIDTH-1:0] i_inst,
output reg [`DATA_WIDTH-1:0] o_immediate_extended
);
    wire [6:0] opcode = i_inst[6:0];
    wire [2:0] funct3 = i_inst[14:12];


    // fields
    wire [11:0] imm_i = i_inst[31:20];
    wire [11:0] imm_s = {i_inst[31:25], i_inst[11:7]};
    wire [12:0] imm_b = {i_inst[31], i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0};
    wire [19:0] imm_u = i_inst[31:12];
    wire [20:0] imm_j = {i_inst[31], i_inst[19:12], i_inst[20], i_inst[30:21], 1'b0};


    always @(*) begin
    // default
        o_immediate_extended = {`DATA_WIDTH{1'b0}};
        case (opcode)
            7'b0010011, // OP-IMM (I)
            7'b0000011, // LOAD (I)
            7'b1100111, // JALR (I)
            7'b1110011: // SYSTEM (I)
            // I-type
            o_immediate_extended = {{20{imm_i[11]}}, imm_i};


            7'b0100011: // STORE (S)
                o_immediate_extended = {{20{imm_s[11]}}, imm_s};


            7'b1100011: // BRANCH (B)
                o_immediate_extended = {{19{imm_b[12]}}, imm_b};


            7'b0110111, // LUI (U)
            7'b0010111: // AUIPC (U)
                o_immediate_extended = {{12{imm_u[19]}}, imm_u, 12'b0};

            7'b1101111: // JAL (J)
                o_immediate_extended = {{11{imm_j[20]}}, imm_j};


            default:
                o_immediate_extended = {`DATA_WIDTH{1'b0}};
        endcase
    end
endmodule