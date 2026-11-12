`timescale 1ns / 1ps

// Execute + Memory Stage
// --------------------------------------
// 1. Runs ALU (R-type, I-type, address calc).
// 2. Evaluates branches/jumps.
// 3. Performs memory access (LW, SW, etc.).
// 4. Forms WB data via wb_mux (ALU/MEM/PC+4).
// 5. Buffers results into EX/MEM→WB register (ex_out_reg).
module execute_stage(
    input  clk, rst_n,
    input auipc, 
    input [31:0] pc, rs1_data, rs2_data, imm, pc4E,
    input [`ADDR_WIDTH - 1 : 0] rdE,
    input [3:0] alu_ctrl,
    //forwarding unit
    input [1:0] forward1, forward2,
    input [31:0] resultM_f, resultW_f, resultD_f,
    // control signals from Decode
    input alu_src, reg_writeE, mem_readE,
    input [1:0] wb_selE,
    
    output reg [`DATA_WIDTH - 1 : 0] resultM,
    output reg [`DATA_WIDTH - 1 : 0] bM, // wdata for memory
    output reg reg_writeM, mem_readM,
    output reg [1:0] wb_selM,
    output reg [`ADDR_WIDTH - 1 : 0] rdM,
    output reg [`DATA_WIDTH - 1 : 0] pc4M
);
    // ----------------------------------
    // ALU
    // ----------------------------------
    wire [31:0] result;
    reg [31:0] b;
    wire [31:0] alu_src_b;
    wire        alu_zero, alu_neg;
    reg [31:0] a;
    wire [31:0] a_1 = auipc ? pc : rs1_data;
    // forwarding mux
    always @(*) begin
        case(forward1)
            2'b00: a = a_1;
            2'b01: a = resultW_f;
            2'b10: a = resultM_f;
            2'b11: a = resultD_f;
            default: a = a_1;
        endcase
        case(forward2)
            2'b00: b = rs2_data;
            2'b01: b = resultW_f;
            2'b10: b = resultM_f;
            2'b11: b = resultD_f;
            default: b = rs2_data;
        endcase
    end
    assign alu_src_b = (alu_src) ? imm : b;
    alu alu_inst (
        .a        (a),
        .b        (alu_src_b),
        .alu_ctrl (alu_ctrl),
        .result   (result),
        .zero     (alu_zero)
    );
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            reg_writeM <= 0;
            wb_selM <= 2'b0;
            resultM <= 32'b0;
            mem_readM <= 1'b0; 
            rdM <= 5'b0;
            pc4M <= 32'b0;
            bM <= 32'b0;
        end
        else begin
            reg_writeM <= reg_writeE;
            wb_selM <= wb_selE;
            resultM <= result;
            mem_readM <= mem_readE; 
            rdM <= rdE;
            pc4M <= pc4E;            
            bM <= b;
        end
    end
endmodule
