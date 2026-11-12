`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.02.2026 18:36:39
// Design Name: 
// Module Name: top_cpu_uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_cpu_uart(
    input  rst_n ,rx, load_en,
//    input  wire clk_p,
//    input  wire clk_n,
input clk,
    output pc_op
    );
//    wire clk; 

//    IBUFDS #(
//        .DIFF_TERM("TRUE"), 
//        .IBUF_LOW_PWR("FALSE")
//    ) ibufds_clk (
//        .I (clk_p),
//        .IB(clk_n),
//        .O (clk)
//    );
    
    wire [11:0] load_addr;
    wire [31:0] load_data;
    uart_rx  rx_0(.clk(clk), .rst_n(rst_n), 
                  .rx(rx), .load_addr(load_addr),
                  .load_data(load_data));
    cpu cpu_0( .clk(clk) , .rst_n(rst_n), 
               .load_en(load_en), .load_addr(load_addr), 
               .load_data(load_data), .pc_op(pc_op)); 
    
endmodule

