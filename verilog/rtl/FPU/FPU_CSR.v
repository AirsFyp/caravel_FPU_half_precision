module FPU_CSR(clk,rst_l,CSR_Read,CSR_Write,CSR_Addr,CSR_Write_Data,CSR_Read_Data,S_flag,fpu_active,fpu_complete,illegal_instr,Fpu_Frm);
    input clk,rst_l,CSR_Write,CSR_Read,fpu_active,fpu_complete,illegal_instr;
    input [11:0]CSR_Addr;
    input [31:0]CSR_Write_Data;
    input [4:0]S_flag;
    output [31:0]CSR_Read_Data;
    output [2:0] Fpu_Frm;

    reg [4:0] fflag;
    reg [2:0] frm;
    reg [31:0]fcsr;
    wire fflag_w,frm_w,fcsr_w;

    assign fflag_w = (~rst_l) ? 1'b0 : (CSR_Addr == 12'h001) ? 1'b1 : 1'b0;
    assign frm_w = (~rst_l) ? 1'b0 : (CSR_Addr == 12'h002) ? 1'b1 : 1'b0;
    assign fcsr_w = (~rst_l) ? 1'b0 : (CSR_Addr == 12'h003) ? 1'b1 : 1'b0;
    assign CSR_Read_Data = (~rst_l) ? 32'h00000000 : (({32{(CSR_Read & fflag_w)}} & {27'h000000,fflag}) | 
                                                     ({32{(CSR_Read & frm_w)}} & {29'h0000000,frm}) | 
                                                     ({32{(CSR_Read & fcsr_w)}} & fcsr));
    assign Fpu_Frm = (~rst_l) ? 3'b000 : (fpu_active & (~illegal_instr)) ? frm : 3'b000;


    always @ (posedge clk)
    begin
        if (~rst_l)
        begin
            fflag <= 5'b00000;
            frm <= 3'b000;
            fcsr <= 32'h00000000;
        end

        else
        begin
            fflag <= (fflag_w & CSR_Write) ? CSR_Write_Data[4:0] : (fcsr_w & CSR_Write) ? CSR_Write_Data[4:0] : (fpu_complete) ? (fflag[4:0] | S_flag[4:0]) : fflag;
            frm <= (frm_w & CSR_Write) ? CSR_Write_Data[2:0] : (fcsr_w & CSR_Write) ? CSR_Write_Data[7:5] : frm;
            fcsr <= (fcsr_w & CSR_Write) ? {24'h00000,CSR_Write_Data[7:0]} : (fpu_complete) ? ({24'h000000,frm,(fflag[4:0] | S_flag[4:0])}) : fcsr;
        end
    end

endmodule