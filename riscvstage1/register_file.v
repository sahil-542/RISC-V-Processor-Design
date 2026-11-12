`timescale 1ns / 1ps
`include "definitions.vh"

module register_file(
    input [`ADDR_WIDTH - 1 : 0] rs1,rs2, rd,
    input [`DATA_WIDTH - 1 : 0] wr_data,
    input we,
    input clk, rst_n,
    output reg [`DATA_WIDTH - 1: 0] rs1_data, rs2_data
);
     reg [`DATA_WIDTH - 1:0] r [`DATA_WIDTH - 1 : 0];
        integer i;
    always @(posedge clk)begin
         if (!rst_n) begin
             for (i=0;i<32;i=i+1) r[i] <= {`DATA_WIDTH{1'b0}};
         end
         else if(rd != 0 && we) r[rd] <= wr_data;
    end
    always @(*) begin
        rs1_data = (rs1==0) ? {`DATA_WIDTH{1'b0}} : r[rs1];
        rs2_data = (rs2==0) ? {`DATA_WIDTH{1'b0}} : r[rs2];
    end
endmodule