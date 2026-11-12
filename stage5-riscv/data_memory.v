`timescale 1ns / 1ps
module data_memory(
    input clk, 
    input memwrite,
    input [13:0] addr,
    input [31:0] wdata,
    output reg [31:0] rdata
    );
    reg [31:0] memory [4095:0]; 
	integer i;
    initial begin
        for(i=0;i<32;i=i+1)
            memory[i]<=0;
    end
    always @(posedge clk) begin
        if(memwrite)
            memory[addr[13:2]]<=wdata;
    end    
    always @(*) begin
        rdata<=memory[addr[13:2]];
    end
endmodule