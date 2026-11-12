`timescale 1ns / 1ps

module data_memory(
     input clk, 
    input rst_n,
    input memread, 
    input memwrite,
    input [13:0] addr,
    input [31:0] wdata,
    output reg [31:0] rdata
    );

reg [31:0] memory [0:32];
 // 16K words = 64KB   *** change later ***
    integer i;

    // Write (synchronous)
    always @(posedge clk) begin
         if (!rst_n) begin
             rdata <= 32'b0;
             for (i = 0; i<33; i = i +1 ) begin
                 memory[i] <= 31'b0;
             end
         end
        if (memwrite) begin
            memory[addr] <= wdata;  // word addressing
        end
    end
    
    always @(*) begin
       if (memread) rdata <= memory[addr];
        else rdata <= 32'b0;
    end
 
endmodule
