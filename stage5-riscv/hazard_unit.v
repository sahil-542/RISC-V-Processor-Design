module hazard_unit (
    input clk,
    input [4:0] rs1E, rs2E,
    input [4:0] rdM, rdW,
    input branch_taken, reg_writeW, reg_writeM,
    // output stallF, stallD, stallE,
    output reg flush_FD_reg, flush_DE_reg,
    output reg [1:0] forward1, forward2
);
        // rs1D == rdE ==> result
        // rs2D == rdE ==> result
    //forwarding unit
    always @(*) begin
        if(reg_writeW & (rdW != 0) & (rs1E == rdW)) forward1 = 2'b01; // need in exe but in wr
        else if(reg_writeM & (rdM != 0) & (rs1E == rdM)) forward1 = 2'b10; //need in exe but in mem
        else forward1 = 2'b00;
        
        if(reg_writeW & (rdW != 0) & (rs2E == rdW)) forward2 = 2'b01;
        else if(reg_writeM & (rdM != 0) & (rs2E == rdM)) forward2 = 2'b10;
        else forward2 = 2'b00;
    end
    always @(*) begin
         flush_DE_reg = branch_taken;
         flush_FD_reg = branch_taken;
    end         
endmodule