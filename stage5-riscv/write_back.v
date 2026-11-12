`include "definitions.vh"
(* use_dsp = "yes" *)
module write_back(
    input [`DATA_WIDTH - 1 : 0] result, mem_data,
    input [1:0] wb_sel,
    input [`ADDR_WIDTH - 1 : 0] rd_addr,   
    input regwrite, 
    input [31:0] pc4,
    output [31:0] out_wb_data,     // muxed, latched writeback data
    output [4:0]  out_rd_addr,     // latched rd
    output        out_regwrite   // latched regwrite
    );
 // ----------------------------------
    // Writeback Mux (before pipeline reg)
    // ----------------------------------
    // DECLARE the muxed data wire

    wb_mux wb_inst (
        .alu_in (result),
        .mem_in (mem_data),
        .pc4_in (pc4),
        .wb_sel (wb_sel),
        .wb_data(out_wb_data)
    );
    
    // ----------------------------------
    // Pipeline Register: latch WB-side signals
    // ----------------------------------
    assign out_rd_addr = rd_addr;
    assign out_regwrite = regwrite;

endmodule    