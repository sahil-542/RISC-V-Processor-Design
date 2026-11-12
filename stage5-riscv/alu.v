`timescale 1ns / 1ps

`include "definitions.vh"
module alu (
	input  wire [`DATA_WIDTH-1:0] a,
    input  wire [`DATA_WIDTH-1:0] b,
    input  wire [3:0]       alu_ctrl,
    output reg  [`DATA_WIDTH-1:0] result,
    output wire             zero    // 1 if result == 0(zero flag)     // sign bit of result (for signed tests)
);

    wire [$clog2(`DATA_WIDTH)-1:0] shamt;
    assign shamt = b[$clog2(`DATA_WIDTH)-1:0]; // used to determine the lower range of how much shift can be done

    always @(*) begin
        case (alu_ctrl)
            `OP_ALU_ADD:  result = a + b;
            `OP_ALU_SUB:  result = $signed(a) - $signed(b);
            `OP_ALU_SLL:  result = a << shamt;
            `OP_ALU_SLT:  result = ($signed(a) < $signed(b)) ? {{(`DATA_WIDTH-1){1'b0}},1'b1} : {`DATA_WIDTH{1'b0}};
            `OP_ALU_SLTU: result = (a < b) ? {{(`DATA_WIDTH-1){1'b0}},1'b1} : {`DATA_WIDTH{1'b0}};
            `OP_ALU_XOR:  result = a ^ b;
            `OP_ALU_SRL:  result = a >> shamt;
            `OP_ALU_SRA:  result = $signed(a) >>> shamt;
            `OP_ALU_OR:   result = a | b;
            `OP_ALU_AND:  result = a & b;
            `OP_ALU_PASS: result = b; // direct output passed to load upper immediate in register
            default:  result = {`DATA_WIDTH{1'b0}};
        endcase
    end

    assign zero = (result == {`DATA_WIDTH{1'b0}});
//    assign neg  = (alu_ctrl==`OP_ALU_SLT | alu_ctrl==`OP_ALU_SLTU) ? result[0] : result[`DATA_WIDTH-1];

endmodule