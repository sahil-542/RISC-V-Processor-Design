`timescale 1ns / 1ps

`include "definitions.vh"

module branch_unit (
    input  wire        i_branch,       // 1 if instruction is branch
    input  wire [2:0]  funct3,         // branch type        
    input  wire [31:0] rs1_data, rs2_data,     // also from ALU (for SLT/SLTU ops)
    output reg         o_branch_taken
);
    wire gt,lt,eq;
    comparator cp(rs1_data,rs2_data,eq,gt,lt);
   always @(*) begin
        o_branch_taken = 1'b0;
        if (i_branch) begin
            case (funct3)
                `BRANCH_BEQ:  o_branch_taken = eq;        // rs1 == rs2
                `BRANCH_BNE:  o_branch_taken = ~eq;       // rs1 != rs2
                `BRANCH_BLT:  o_branch_taken = lt; // SLT gives 1 if a<b
                `BRANCH_BGE:  o_branch_taken = ~lt; 
                `BRANCH_BLTU: o_branch_taken = ($signed(rs1_data) < $signed(rs2_data)); // SLTU gives 1 if a<b unsigned
                `BRANCH_BGEU: o_branch_taken = ($signed(rs1_data) >= $signed(rs2_data));
                default:     o_branch_taken = 1'b0;
            endcase
        end
    end
endmodule