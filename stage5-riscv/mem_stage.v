`define ADDR 32
module mem_stage(
    input clk, rst_n,
    input mem_read, mem_write,
    input [`DATA_WIDTH - 1 : 0] resultM, pc4M,
    input [`ADDR_WIDTH - 1 : 0] rdM,  
    input reg_writeM,
    input [1:0] wb_selM,  
    input [`ADDR - 1 : 0]result,
    input [`DATA_WIDTH - 1 : 0] b,
    output reg reg_writeW,
    output reg [1:0] wb_selW,
    output reg [`ADDR_WIDTH - 1 : 0] rdW,
    output reg [`DATA_WIDTH - 1 : 0] resultW, mem_resultW, pc4W
    );
    wire [31:0] mem_rd_data;
    data_memory data_mem_inst (
        .clk     (clk),
        .memwrite(mem_write),
        .addr    (result),  // ALU computed address
        .wdata   (b),    // store payload
        .rdata   (mem_rd_data)
    );

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            reg_writeW <= 0;
            wb_selW <= 2'b0;
            rdW <= 5'b0;
            resultW <= 32'b0;
            mem_resultW <= 32'b0;
            pc4W <= 32'b0;

        end
        else begin
            reg_writeW <= reg_writeM;
            wb_selW <= wb_selM;
            rdW <= rdM;
            resultW <= resultM;
            mem_resultW <= mem_rd_data;
            pc4W <= pc4M;        
        end
    end
endmodule
