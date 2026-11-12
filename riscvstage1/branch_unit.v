`timescale 1ns / 1ps

`include "definitions.vh"

module branch_unit (
    input  wire        i_branch,       // 1 if instruction is branch
    input wire         jump,             // 1 if instruction is jump
    input wire         jumpr,            // 1 if instruction is jump register
    input  wire [31:0]  pc,             // current pc
    input  wire [31:0]  imm,            // immediate (branch target offset
    input wire [31:0]  rs1_data,      // rs1 data
    output wire [31:0] branch_target, // target address if branch taken
    input  wire [2:0]  funct3,         // branch type
    input  wire        zero,           // from ALU
    input  wire        neg,            // sign bit from ALU (not always needed here)
    output wire        branch_taken
);

    reg o_branch_taken;
   always @(*) begin
        o_branch_taken = 1'b0;
        if (i_branch) begin
            case (funct3)
                `BRANCH_BEQ:  o_branch_taken = zero;        // rs1 == rs2
                `BRANCH_BNE:  o_branch_taken = ~zero;       // rs1 != rs2
                `BRANCH_BLT:  o_branch_taken = neg; // SLT gives 1 if a<b
                `BRANCH_BGE:  o_branch_taken = ~neg; 
                `BRANCH_BLTU: o_branch_taken = neg; // SLTU gives 1 if a<b unsigned
                `BRANCH_BGEU: o_branch_taken = ~neg;
                default:     o_branch_taken = 1'b0;
            endcase
        end
    end
    assign branch_taken = o_branch_taken | jump | jumpr;
    assign branch_target = (jumpr) ? ((rs1_data + imm) & ~32'b1) : (pc + imm);

endmodule
