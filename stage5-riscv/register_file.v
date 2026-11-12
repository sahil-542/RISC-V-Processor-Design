`timescale 1ns / 1ps
`include "definitions.vh"

module register_file(
    input [`ADDR_WIDTH - 1 : 0] rs1,rs2, rd,
    input [`DATA_WIDTH - 1 : 0] wr_data,
    input we,
    input clk, 
    (* max_fanout = 50 *) input rst_n,
    (* max_fanout = 50 *) output reg [`DATA_WIDTH - 1: 0] rs1_data, rs2_data
);

    (* ram_style = "block" *) reg [`DATA_WIDTH - 1:0] r1 [`DATA_WIDTH - 1 : 0];
    (* ram_style = "block" *) reg [`DATA_WIDTH - 1:0] r2 [`DATA_WIDTH - 1 : 0];
    integer i;


    initial begin
        for(i=0;i<32;i=i+1) begin
            r1[i]<=0;
            r2[i]<=0;
        end
        rs1_data<=0;
        rs2_data<=0;
    end

    always @(posedge clk) begin
        if(we&(rd!=5'b0))
            r1[rd]<=wr_data;
    end  

    always @(posedge clk) begin
        if(we&(rd!=5'b0))
            r2[rd]<=wr_data;
    end  

    always @(*) begin
        if(we & (rd == rs1)) rs1_data <= wr_data;
        else rs1_data<=r1[rs1];
        if(we & (rd == rs2)) rs2_data <= wr_data; 
        else rs2_data<=r2[rs2];
    end

endmodule