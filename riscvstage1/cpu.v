`timescale 1ps/1ps
`include "definitions.vh"

module cpu(input clk, rst_n,
           input load_en,
           input [11:0]load_addr,
           input [31:0] load_data,
           output pc_op);
           
    wire        branch_taken;
    wire [31:0] branch_target;
    wire [31:0] f_instr, f_pc;
    fetch fetch_0(
    .clk (clk)         ,
    .rst_n(rst_n)        ,
    .branch_taken(branch_taken ) ,
    .branch_target(branch_target),
    .id_pc(f_pc)        ,
    .id_instr(f_instr)     ,
    .load_en(load_en)      ,
    .load_addr(load_addr)    ,
    .load_data(load_data)     
);


    wire mem_read, mem_write, alu_src, reg_write, branch, jump, jumpr, auipc;
    wire [1:0]  wb_sel;
    wire [3:0]  alu_ctrl;
    wire [4 : 0] rs1_e, rs2_e, rd_e;

    controlunit control_unit(
        .id_instr(f_instr),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .alu_ctrl(alu_ctrl),
        .branch(branch),
        .jump(jump),
        .wb_sel(wb_sel),
        .rs1_e(rs1_e), .rs2_e(rs2_e), .rd_e(rd_e),
        .auipc(auipc),
        .jumpr(jumpr)
    );

    wire [31:0] wr_data;
    wire [31:0] rs1_data, rs2_data;

    register_file reg_file(
        .rs1(rs1_e),
        .rs2(rs2_e),
        .rd(rd_e),
        .wr_data(wr_data),
        .we(reg_write),
        .clk(clk),
        .rst_n(rst_n),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    assign pc_op = f_pc[0];
    wire [31:0] immediate_extended;
    sign_ext immediate_value(
        .i_inst(f_instr),
        .o_immediate_extended(immediate_extended)
    );


    wire [31:0] alu_result;
    wire        zero, neg;


    branch_unit branch_unit(
        .i_branch(branch),
        .jump(jump),
        .jumpr(jumpr),
        .funct3(f_instr[14:12]),
        .rs1_data(rs1_data),
        .imm(immediate_extended),
        .pc(f_pc),
        .zero(zero),
        .neg(neg),
        .branch_taken(branch_taken),
        .branch_target(branch_target)
    );

    alu alu_inst(
        .a(auipc ? f_pc : rs1_data),
        .b(alu_src ? immediate_extended : rs2_data),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero),
        .neg(neg)
    );

    wire [31:0] mem_rd_data;

    data_memory data_mem_inst(
        .clk(clk),
        .rst_n(rst_n),
        .memread(mem_read),
        .memwrite(mem_write),
        .addr(alu_result[15:2]),
        .wdata(rs2_data),
        .rdata(mem_rd_data)
    );

    wb_mux wb_inst(
        .alu_in(alu_result),
        .mem_in(mem_rd_data),
        .pc4_in(f_pc + 4),
        .wb_sel(wb_sel),
        .wb_data(wr_data)
    );

endmodule