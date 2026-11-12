`timescale 1ns / 1ps

module pc(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        branch_taken,
    input  wire [31:0] branch_target,
    output reg  [31:0] pc,
    input  wire        load_en  
);

    // synchronous PC register with active-low reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) pc <= 32'hFFFF_FFFC;  // so that first pc is 0
        else if(load_en) pc <= 32'hFFFF_FFFC;
        else if (!load_en) pc <= branch_taken ? branch_target : pc + 32'd4;
    end
    
endmodule
