module Main_Decode(clk,rst_l,Instruction,S_flag,Flag_LI,Flag_ADDI,RS1_d,RS2_d,Activation_Signal,result,Flag_Reset,Flag_CSR,Flag_CSR_r,fpu_active,fpu_complete,sfpu_op,fpu_pre,fs1_data,fs2_data,fs3_data,valid_execution,illegal_config,float_control,halt_req,fpu_result_1,fpu_rounding,dec_i0_rs1_en_d,dec_i0_rs2_en_d,fpu_sel,fpu_result_rd_w,fpu_complete_rd);


    input clk,rst_l,Activation_Signal,fpu_active,fpu_complete,fpu_complete_rd;
    input [4:0]S_flag;
    input [31:0]Instruction,result,fpu_result_rd_w;
    input [15:0]fpu_result_1;
    output Flag_ADDI,Flag_LI,Flag_Reset,Flag_CSR,CSR_Write,valid_execution,illegal_config,halt_req,dec_i0_rs1_en_d,dec_i0_rs2_en_d;
    output [31:0]RS1_d,RS2_d;
    output [15:0]fs1_data,fs2_data,fs3_data;
    output reg Flag_CSR_r;
    output [23:0]sfpu_op;
    output [2:0]fpu_pre,fpu_rounding,fpu_sel;
    output [3:0]float_control;
    
    
    wire [2:0] fpu_rnd,Fpu_Frm;
    wire [11:0]IMM_ADDI,CSR_Addr;
    wire [31:0]IMM_LI;
    reg [4:0]rd,rd_address;
    wire [4:0]rs1,rs2,rs1_address,rs2_address;
    //reg [31:0]Instruction_reg;
    wire [31:0]gpr_rs1,gpr_rs2;
    wire [2:0] Function_CSR;
    wire [31:0] CSR_Read_Data,CSR_Write_Data;
    wire rs1_en,rs2_en;
    reg [31:0] CSR_Read_Data_r;
    reg CSR_Read_r;
    wire CSR_Read;
    wire [2:0]scalar_control;
    wire write_en;
    wire illegal_instr;
    wire [23:0]sfpu_op_w;

    always @(posedge clk)
    begin
       /* if (rst_l)
            Instruction_reg <= Instruction;
        else
            Instruction_reg <= 32'h00000000;
        */

        if (rst_l)
        begin
            CSR_Read_Data_r <= CSR_Read_Data;
            CSR_Read_r <= (CSR_Read & ~fpu_active);
            Flag_CSR_r <= Flag_CSR;
        end
        else
        begin
            CSR_Read_Data_r <= 32'h00000000;
            CSR_Read_r <= 1'b0; 
            Flag_CSR_r <= 1'b0;
        end

        rd = (~rst_l) ? 5'b00000 : (Instruction[11:7] != 5'b00000) ? Instruction[11:7] : 5'b00000;

        //Flag_ADDI = (~rst_l) ? 1'b0 : (Instruction[6:0] == 7'b0010011) ? 1'b1 : 1'b0;
        //Flag_LI = (~rst_l) ? 1'b0 : (Instruction[6:0] == 7'b0110111) ? 1'b1 : 1'b0;
        //RS2_d = (~rst_l) ? 32'h00000000 : Flag_LI ? IMM_LI : (Flag_ADDI) ? {{20{IMM_ADDI[11]}},IMM_ADDI} : gpr_rs2;
        //RS1_d = (~rst_l) ? 32'h00000000 : gpr_rs1;

    end

    dec_gpr_ctl Int_Reg_file(
                            .clk(clk),
                            .rst_l(rst_l),
                            .rden0(rs1_en),
                            .rden1(rs2_en),
                            .raddr0(rs1),
                            .raddr1(rs2),
                            .wen0(write_en),
                            .waddr0(rd),
                            .wd0((CSR_Read_r) ? CSR_Read_Data_r : (fpu_complete_rd & (~Activation_Signal) & (~CSR_Read_r)) ? fpu_result_rd_w : result),
                            .rd0(gpr_rs1),
                            .rd1(gpr_rs2),
                            .scan_mode(1'b0)
                            );


    FPU_CSR CSR(
                .clk(clk),
                .rst_l(rst_l),
                .S_flag(S_flag),
                .fpu_complete(fpu_complete),
                .CSR_Read(CSR_Read),
                .CSR_Write(CSR_Write),
                .CSR_Addr(CSR_Addr),
                .CSR_Write_Data(CSR_Write_Data),
                .CSR_Read_Data(CSR_Read_Data),
                .fpu_active(fpu_active),
                .illegal_instr(illegal_instr),
                .Fpu_Frm(Fpu_Frm)
                );

    FPU_decode FPU_Decoder(
                          .clk(clk),
                          .rst_l(rst_l),
                          .instr(Instruction),
                          .fpu_active(fpu_active),
                          .fpu_complete(fpu_complete),
                          .fpu_result_1(fpu_result_1),
                          .scalar_control(scalar_control),
                          .rs1_address(rs1_address),
                          .rs2_address(rs2_address),
                          .rd_address(rd_address),
                          .illegal_instr(illegal_instr),
                          .sfpu_op(sfpu_op_w),
                          .fpu_rnd(fpu_rnd),
                          .fpu_pre(fpu_pre),
                          .fs1_data(fs1_data),
                          .fs2_data(fs2_data),
                          .fs3_data(fs3_data),
                          .valid_execution(valid_execution),
                          .illegal_config(illegal_config),
                          .scan_mode(1'b0),
                          .float_control(float_control),
                          .halt_req(halt_req),
                          .fpu_sel(fpu_sel)
                          );

    // ADDI & LUI instructions ASSIGNEMENTS
    assign IMM_ADDI = (~rst_l) ? 12'h000 : Instruction[31:20];
    assign IMM_LI = (~rst_l) ? 32'h00000000 : {Instruction[31:12],12'h000};
    assign Flag_ADDI = (~rst_l) ? 1'b0 : (Instruction[6:0] == 7'b0010011) ? 1'b1 : 1'b0;
    assign Flag_LI = (~rst_l) ? 1'b0 : (Instruction[6:0] == 7'b0110111) ? 1'b1 : 1'b0;
    assign Flag_Reset = (~rst_l) ? 1'b0 : (Instruction[6:0] == 7'b0010000) ? 1'b1 : 1'b0; 


    // INTEGER REGISTER  FILE ASSIGNEMENTS
    assign rs1_en = (~rst_l) ? 1'b0 : ((Instruction[11:7] != 5'b00000) & (~fpu_active)) ? 1'b1 : (fpu_active & ~illegal_instr) ? scalar_control[0] : 1'b0;
    assign rs2_en = (~rst_l) ? 1'b0 : (Instruction[11:7] != 5'b00000) ? 1'b1 : (fpu_active & ~illegal_instr) ? scalar_control[1] : 1'b0;
    assign rs1 = (~rst_l) ? 5'b00000 : (Flag_ADDI) ? Instruction[19:15] : ((Function_CSR == 3'b001) & Flag_CSR) ? Instruction[19:15] : (fpu_active & ~illegal_instr) ? rs1_address : 5'b00000;
    assign rs2 = (~rst_l) ? 5'b00000 : (fpu_active & ~illegal_instr) ? rs2_address : 5'b00000;
    assign RS2_d = (~rst_l) ? 32'h00000000 : Flag_LI ? IMM_LI : (Flag_ADDI) ? {{20{IMM_ADDI[11]}},IMM_ADDI} : gpr_rs2;
    assign RS1_d = (~rst_l) ? 32'h00000000 : /*(Flag_LI) ? 32'h00000000 :*/ gpr_rs1;
    assign write_en = (~rst_l) ? 1'b0 : (Activation_Signal | CSR_Read_r)  ? 1'b1 : (fpu_complete_rd & (~Activation_Signal)) ? 1'b1 : 1'b0;

    // CSRRW & CSRRWI instructions ASSIGNEMENTS
    assign Flag_CSR = (~rst_l) ? 1'b0 : (Instruction[6:0] == 7'b1110011) ? 1'b1 : 1'b0;
    assign Function_CSR = (~rst_l) ? 3'b000 : (Flag_CSR) ? Instruction[14:12] : 3'b000;
    assign CSR_Addr = (~rst_l) ? 12'h000 : (fpu_active & (~illegal_instr) & (~fpu_complete)) ? 12'h001 : Instruction[31:20];
    assign CSR_Read = (~rst_l) ? 1'b0 : ((Instruction[11:7] != 5'b00000) & Flag_CSR) ? 1'b1 : (fpu_active & (~illegal_instr) & (~fpu_complete)) ? 1'b1 : 1'b0;
    assign CSR_Write = (~rst_l) ? 1'b0 : (Flag_CSR) ? 1'b1 : (fpu_active & (~illegal_instr) & fpu_complete) ? 1'b1 : 1'b0;
    assign CSR_Write_Data = (~rst_l) ? 32'h00000000 : (Flag_CSR & (Function_CSR == 3'b101)) ? {27'h0000000,Instruction[19:15]} : RS1_d;
    assign fpu_rounding = (~rst_l) ? 3'b000 : (fpu_active & (~illegal_instr) & (fpu_rnd==3'b111)) ? Fpu_Frm : (fpu_active & (~illegal_instr) & (fpu_rnd!=3'b111)) ? fpu_rnd : 3'b000;
    assign dec_i0_rs1_en_d = (~rst_l) ? 1'b0 : rs1_en;
    assign dec_i0_rs2_en_d = (~rst_l) ? 1'b0 : rs2_en;
    assign sfpu_op = (~rst_l) ? 24'b000000 : sfpu_op_w;

endmodule