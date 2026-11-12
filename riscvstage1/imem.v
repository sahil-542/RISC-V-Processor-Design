`timescale 1ns / 1ps
`include "definitions.vh"

module imem(
    input clk, rst_n,
    input  wire [31:0] addr,
    output reg  [31:0] instr,   // instruction output (registered)
    output reg  [31:0] f_pc ,    // pc forwarded (registered)
    input  wire      load_en      ,
    input  wire [11:0] load_addr    ,
    input  wire [31:0] load_data  
);
    // reg [31:0] mem [0:31];
    // initial begin
    // $readmemh("prog2.mem", mem); // load program into instruction memory
    // end
    // always @(*) begin
    //         instr <= rst_n ? mem[addr[7:2]] : 32'b0;
    //         f_pc  <= rst_n ? addr : 32'b0;
    // end
    reg [31:0] mem [0:4095];
    always @(posedge clk) begin
        if (load_en) begin
            mem[load_addr] <= load_data;
        end
    end
    always @(*) begin
        if (!rst_n) begin
            f_pc    = 32'b0;
            instr = 32'h00000013;
        end
        else if(load_en) begin
            f_pc   = 32'b0;
            instr = 32'h00000013;
        end
        else if (!load_en) begin
            f_pc   = addr;
            instr  = mem[addr[7:2]];
        end
    end
endmodule
