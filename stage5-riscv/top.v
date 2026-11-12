`timescale 1ns / 1ps
`include "definitions.vh"

module top(                      input clk, 
           (* max_fanout = 100 *) input rst_n, 
                                 output pc_op
                                 );
    wire [31:0] rs1_data, rs2_data;
    wire [4:0]  rs1_addr, rs2_addr, rd_addr;
    wire [3:0] alu_ctrlD;

    wire reg_writeD, mem_readD, mem_writeD,alu_srcD, i_branch;
    // latched outputs (for WB stage)
    wire [31:0] out_wb_data;     // muxed, latched writeback data
    wire [31:0] out_store_data;  // latched store payload (rs2)
    wire [4:0]  out_rd_addr;     // latched rd
    wire        out_regwrite;    // latched regwrite
    wire [1:0]  out_wb_sel;      // (optional) latched wb_sel for tracing
    
    // branch wires (combinational from this stage)
    wire        branch_taken;
    wire [31:0] branch_target;
    wire [31:0] f_pc, f_pc4, f_instr, id_pc, id_pc4, id_instr;
    //hazard 
    wire flush_DE_reg, flush_FD_reg;
    wire [1:0] forward1, forward2;
    
    fetch fetch_stage(
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_FD_reg),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .id_pc(id_pc),
        .id_pc4(id_pc4),        
        .id_instr(id_instr)
        );
    
    wire [`INST_WIDTH - 1 : 0] o_immediate_extended;
    wire [31 : 0] pcD;
    wire [4 : 0] rs1D, rs2D, rdD, rs1E, rs2E;
    wire [2:0] funct3_out_of_d;
    wire [1:0] wb_sel;
    wire auipc, i_branchD, jumprD, jumpD;
     
    wire [4:0]  rdE;
    wire [1:0]  wb_selE;
    wire [2:0] funct3_out_of_dE;
    wire [3:0] alu_ctrlE;
    wire [31:0] rs1_dataE, rs2_dataE;
    wire reg_writeE, mem_readE, mem_writeE,alu_srcE, branchE;
    wire jumpE, i_branchE, jumprE;
    wire [31 : 0] pcE, ie_pc4;
    wire [`INST_WIDTH - 1 : 0] immediate_extendedE;
    wire branch_for_hazard;
    decode u_decode (
    .id_pc              (id_pc),
    .id_instr           (id_instr),
    .clk                (clk),
    .rst_n              (rst_n),
    .flush              (flush_DE_reg),
    .ena_wr             (out_regwrite),
    .wr_data            (out_wb_data),
    .rd                 (out_rd_addr),
    .rs1_dataE          (rs1_dataE),
    .rs2_dataE          (rs2_dataE),
    .immediate_extendedE(immediate_extendedE),
    .reg_writeE         (reg_writeE),
    .mem_readE          (mem_readE),
    .alu_srcE           (alu_srcE),
    .alu_ctrlE          (alu_ctrlE),
    .ie_pc4             (ie_pc4),
    .ie_pc              (pcE),
    .rs1E               (rs1E),
    .rs2E               (rs2E),
    .rdE                (rdE),
    .wb_selE            (wb_selE),
    .auipcE             (auipcE),
    .o_branch_taken(branch_taken),
    .branch_target(branch_target)
);



    wire [31:0] wb_data_ex;     // muxed, latched writeback data
    wire [4:0]  rd_addr_ex;     // latched rd
    wire        regwrite_ex;    // latched regwrite
    wire [31:0] resultE,bE,bM;
    wire [31:0] pc4M, resultM;
    wire [4:0] rdM;
    wire [1:0] wb_selM;
    
    wire reg_writeW;
    wire [1:0] wb_selW;
    wire [4:0] rdW;
    wire [31:0] resultW, mem_resultM, pc4W, mem_resultW;
    
     execute_stage execute_stage_int(
        .clk(clk),
        .rst_n(rst_n),
        .auipc(auipcE),
        .pc(pcE),
        .rs1_data(rs1_dataE),
        .rs2_data(rs2_dataE),
        .imm(immediate_extendedE),
        .pc4E(ie_pc4),
        .rdE(rdE),
        .alu_ctrl(alu_ctrlE),
        .forward1(forward1),
        .forward2(forward2),
        .resultM_f(resultM),
        .resultW_f(out_wb_data),
        .resultD_f(out_wb_data),
        .alu_src(alu_srcE),
        .reg_writeE(reg_writeE),
        .mem_readE(mem_readE),
        .wb_selE(wb_selE),
        .resultM(resultM),
        .bM(bM), // for write data in memory
        
        .reg_writeM(reg_writeM),
        .mem_readM(mem_readM),
        .wb_selM(wb_selM),
        .rdM(rdM),
        .pc4M(pc4M)
        );
    
    //execute mem reg



    wire [`DATA_WIDTH - 1 : 0] read_data;
    //memory stage
    mem_stage mem(
            .clk(clk),
            .rst_n(rst_n),
            .mem_read(mem_readM),
            .mem_write(mem_writeM),
            .resultM(resultM),
            .pc4M(pc4M),
            .rdM(rdM),
            .reg_writeM(reg_writeM),
            .wb_selM(wb_selM),
            .result(resultM),
            .b(bM),
            .reg_writeW(reg_writeW),
            .wb_selW(wb_selW),
            .rdW(rdW),
            .resultW(resultW),
            .mem_resultW(mem_resultW),
            .pc4W(pc4W)
            );

    //mem write_back reg
    
    // write back stage
    write_back write_back_inst (
        .result(resultW),
        .mem_data(mem_resultW),
        .wb_sel(wb_selW),
        .rd_addr(rdW),
        .regwrite(reg_writeW),
        .pc4(pc4W),
        .out_wb_data(out_wb_data),
        .out_rd_addr(out_rd_addr),
        .out_regwrite(out_regwrite)
    );
    
    // hazard unit
    hazard_unit hazard(
        .clk(clk),
        .rs1E(rs1E),
        .rs2E(rs2E),
        .rdM(rdM),
        .rdW(rdW),
        .branch_taken(branch_taken),
        .reg_writeW(reg_writeW),
        .reg_writeM(reg_writeM),        
        .flush_FD_reg(flush_FD_reg),
        .flush_DE_reg(flush_DE_reg),
        .forward1(forward1),
        .forward2(forward2)
        );
        assign pc_op = pc4W[10];
endmodule