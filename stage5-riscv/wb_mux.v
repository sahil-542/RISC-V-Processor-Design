`timescale 1ns / 1ps

module wb_mux (
    input  wire [31:0] alu_in,   // ALU result
    input  wire [31:0] mem_in,   // Data memory output
    input  wire [31:0] pc4_in,   // PC+4
    input  wire [1:0]  wb_sel,   // Selector
    output reg  [31:0] wb_data   // Final writeback data
);

    always @(*) begin
        case (wb_sel)
            2'b00: wb_data = alu_in;  // ALU result
            2'b01: wb_data = mem_in;  // Load data
            2'b10: wb_data = pc4_in;  // Return address
            default: wb_data = 32'b0; // Safe default
        endcase
    end

endmodule

