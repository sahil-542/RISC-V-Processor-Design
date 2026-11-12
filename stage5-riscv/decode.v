`include "definitions.vh"

`define SIZE 32
module decode(
    input [31:0] id_pc,id_instr,
    input clk, rst_n,
    input flush,
    input ena_wr,
    input [`SIZE - 1 : 0] wr_data,
    input [4 : 0] rd,
    output reg [`SIZE - 1 : 0] rs1_dataE, rs2_dataE,
    output reg [`INST_WIDTH - 1 : 0] immediate_extendedE,
    output reg reg_writeE, mem_readE, alu_srcE,
    output reg [3:0] alu_ctrlE,
    output reg [`SIZE - 1 : 0] ie_pc4, ie_pc,
    output reg [4 : 0] rs1E, rs2E, rdE,
    output reg [1:0] wb_selE,
    output reg auipcE,
    output reg o_branch_taken,
    output reg [31:0] branch_target
);
    wire [3:0] alu_ctrl;
    wire i_branch, jumpr, jump, h_branch_taken;
    wire auipc;
    wire [`INST_WIDTH - 1 : 0] o_immediate_extended;
    wire [4 : 0] rs1_e, rs2_e, rd_e;
    wire [`SIZE - 1 : 0] rs1_data, rs2_data;
    wire [1:0] wb_sel;
    wire reg_write, mem_read, mem_write,alu_src;
    register_file reg_file( .rs1(id_instr[19:15]), .rs2(id_instr[24:20]),
                            .rd(rd), .wr_data(wr_data),
                            .we(ena_wr), .clk(clk), .rst_n(rst_n),
                            .rs1_data(rs1_data), .rs2_data(rs2_data));

    // imm val

    sign_ext immediate_value(.i_inst(id_instr),
                             .o_immediate_extended(o_immediate_extended));

    //control unit 

    // latched outputs (for WB stage)
    controlunit CU(
        .opcode(id_instr[6:0]),   // instruction[6:0]
        .funct3(id_instr[14:12]),   // instruction[14:12]
        .funct7_5(id_instr[30]),   // instruction[31:25]
        .id_instr(id_instr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .reg_write(reg_write),
        .mem_read(mem_read), // 1: from memory to reg; 0: ALU/JAL/LUI
        .mem_write(mem_write),
        .alu_src(alu_src),    // 1: immediate / mem addr, 0: register
        .branch(i_branch),     // branch instruction bit
        .jump(jump),       // jump instruction bit
        .jumpr(jumpr),
        .alu_ctrl(alu_ctrl),    // ALU operation code (see mapping below)
        .wb_sel(wb_sel),   // 0: ALU result, 1: memory data, 2: PC+4 (for JAL/JALR)
        .rs1_e(rs1_e), .rs2_e(rs2_e), .rd_e(rd_e),
        .auipc(auipc)
    );
    
    wire branch_taken;
    branch_unit branch_inst (
        .i_branch      (i_branch),
        .funct3        (id_instr[14:12]), 
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),       
        .o_branch_taken(branch_taken)
    );
    assign h_branch_taken = branch_taken | jumpr | jump;
    wire [31:0] branch_target_w;
    assign branch_target_w = (jumpr) ? (rs1_data + o_immediate_extended) : (id_pc + o_immediate_extended);
    
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n | flush) begin
            // Reset all outputs to 0
            reg_writeE          <= 0;
            mem_readE           <= 0;
            alu_srcE            <= 0;
            alu_ctrlE           <= 0;
            wb_selE            <= 0;

            rs1_dataE           <= 0;
            rs2_dataE           <= 0;
            ie_pc4               <= 0;
            ie_pc               <= 0;            
            rdE                 <= 0;
            rs1E                <= 5'b0;
            rs2E                <= 5'b0;            
            immediate_extendedE <= 0;
            auipcE <= 0;
            
            o_branch_taken <= 1'b0;
            branch_target <= 32'b0;
        end 
        else begin
            // Latch values on clock edge
            reg_writeE          <= reg_write;
            mem_readE           <= mem_read;
            alu_srcE            <= alu_src;
            alu_ctrlE           <= alu_ctrl;
            wb_selE            <= wb_sel;

            rs1_dataE           <= rs1_data;
            rs2_dataE           <= rs2_data;
            ie_pc4               <= id_pc + 4;
            ie_pc               <= id_pc;
            rdE                 <= rd_e;
            rs1E                <= rs1_e;
            rs2E                <= rs2_e;
            immediate_extendedE <= o_immediate_extended;
            auipcE <= auipc;
 
            
            o_branch_taken <= h_branch_taken;
            branch_target <= branch_target_w;
        end
    end
endmodule