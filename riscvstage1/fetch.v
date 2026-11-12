`timescale 1ns / 1ps
`include "definitions.vh"

module fetch (
    input  wire                   clk          ,
    input  wire                   rst_n        ,
    input  wire                   branch_taken ,
    input  wire            [31:0] branch_target,
    output reg  [`DATA_WIDTH-1:0] id_pc        ,
    output reg  [`DATA_WIDTH-1:0] id_instr     ,
    input  wire                   load_en      ,
    input  wire            [11:0] load_addr    ,
    input  wire            [31:0] load_data     
);

    reg [31:0] pc;
    reg [31:0] imem [0:4095];
    always @(posedge clk) begin
        if (load_en) begin
            imem[load_addr] <= load_data;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n | load_en)
            pc <= 32'b0;
        else if (!load_en)
            pc <= branch_taken ? branch_target : pc + 32'd4;
    end

    always @(*) begin
        if (!rst_n) begin
            id_pc    <= 32'b0;
            id_instr <= 32'h00000013;
        end
        else if(load_en) begin
        id_pc    <= 32'b0;
            id_instr <= 32'h00000013;
        end else if (!load_en) begin
            id_pc    <= pc;
            id_instr <= imem[pc[7:2]];
        end
    end


endmodule
