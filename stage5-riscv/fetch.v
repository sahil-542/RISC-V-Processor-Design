`timescale 1ns / 1ps

module fetch(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        branch_taken,
    input  wire [31:0] branch_target,
    input flush,
    output reg  [31:0] id_pc,
    output wire [31:0] id_pc4,
    output reg  [`DATA_WIDTH-1:0] id_instr
);
    // internal PC wire (current instruction PC)

    reg [31:0] addr;
    reg [31:0] mem [0:31];

    initial begin
        $readmemh("inst_mem.mem", mem);
    end

    assign id_pc4 = addr + 32'h4;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) addr <= 32'b0;
        else addr <= branch_taken?branch_target:(id_pc4);
    end
    reg [31:0] id_pc_w, id_instr_w;
    always @(posedge clk) begin
            id_pc_w     <= addr & {32{~branch_taken}};
            id_instr_w  <= mem[addr[7:2]] & {32{~branch_taken}}; 
    end
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n | flush) begin
            id_pc    <= {`DATA_WIDTH{1'b0}};
            id_instr  <= {`DATA_WIDTH{1'b0}};
        end else begin
            id_pc     <= id_pc_w;
            id_instr  <= id_instr_w;
        end 
    end

endmodule
