`include "FPU_FSM_Control_Decode.v"
`include "Sky130_SRAM_1kbyte_Memory.v"
`include "uart_rx_prog.v"
`include "iccm_controller.v"
`include "Main_Decode.v"
`include "Execution.v"
`include "inst_checker.v"


module FPU_FSM_TOP(r_Rx_Serial,clk,rst_l);

    // FPU UART
    input r_Rx_Serial;
    // FPU UART

    // FPU FSM 
    input clk,rst_l;
    // FPU FSM 

    wire o_Rx_DV;
    wire [7:0]o_Rx_Byte;
    wire Active_Process;
    wire we_o;
    wire [31:0]wdata_o;
    wire [13:0]addr_o;
    wire [31:0]PC;
    wire [31:0]Instruction;
    wire Memory_Activation;
    wire [31:0]result;
    wire Activation_Signal;
    wire Flag_ADDI,Flag_LI,Flag_CSR;
    wire [31:0]RS1_d,RS2_d;
    wire [31:0]Instruction_out;
    wire Flag_Reset;
    wire Flag_CSR_r;
    wire Multi_Cycle;
    wire stall_scalar;
    wire scan_mode;
    wire halt_req;
    wire [3:0]float_control;
    wire valid_execution;
    wire illegal_config;
    wire [15:0] fs1_data,fs2_data,fs3_data;
    wire [2:0] fpu_pre,fpu_rounding;
    wire [23:0] sfpu_op;
    wire fpu_active,fpu_complete;
    wire [15:0]fpu_result_1;
    wire dec_i0_rs1_en_d,dec_i0_rs2_en_d;
    wire [4:0]S_flag;
    wire IV_exception;
    wire[2:0]fpu_sel;
    FPU_FSM FSM(
                .clk(clk),
                .rst_l(rst_l),
                .Active_Process(Active_Process),
                .Activation_Signal(Activation_Signal | Flag_CSR_r | fpu_complete),
                .Memory_Activation(Memory_Activation),
                .PC(PC),
                .Instruction(Instruction),
                .Instruction_out(Instruction_out),
                .Multi_Cycle(stall_scalar)
                );

    sky130_sram_1kbyte_1rw1r_32x256_8 SKY130(
                                        .clk0(clk),
                                        .csb0(~we_o),
                                        .web0(~we_o),
                                        .wmask0(4'hF),
                                        .addr0(addr_o[8:1]),
                                        .din0(wdata_o),
                                        .dout0(),
                                        .clk1(clk),
                                        .csb1(~Memory_Activation),
                                        .addr1(PC[9:2]),
                                        .dout1(Instruction)
                                        );

    eb1_iccm_controller ICCM_Controller(
                            .clk_i(clk),
                            .rst_ni(rst_l),
                            .rx_dv_i(o_Rx_DV),
                            .rx_byte_i(o_Rx_Byte),
                            .we_o(we_o),
                            .addr_o(addr_o),
                            .wdata_o(wdata_o),
                            .reset_o(Active_Process)
                        );
    eb1_uart_rx_prog UART(
                        .i_Clock(clk),
                        .rst_ni(rst_l),
                        .i_Rx_Serial(r_Rx_Serial),
                        .CLKS_PER_BIT(16'd348),
                        .o_Rx_DV(o_Rx_DV),
                        .o_Rx_Byte(o_Rx_Byte)
                    );

    Main_Decode Decoder(
                    .clk(clk),
                    .rst_l(rst_l),
                    .Instruction(Instruction_out),
                    .result(result),
                    .Flag_LI(Flag_LI),
                    .Flag_ADDI(Flag_ADDI),
                    .RS1_d(RS1_d),
                    .RS2_d(RS2_d),
                    .Activation_Signal(Activation_Signal),
                    .Flag_Reset(Flag_Reset),
                    .Flag_CSR(Flag_CSR),
                    .S_flag(S_flag),
                    .Flag_CSR_r(Flag_CSR_r),
                    .fpu_active(fpu_active),
                    .fpu_complete(fpu_complete),
                    .sfpu_op(sfpu_op),
                    .fpu_pre(fpu_pre),
                    .fs1_data(fs1_data),
                    .fs2_data(fs2_data),
                    .fs3_data(fs3_data),
                    .valid_execution(valid_execution),
                    .illegal_config(illegal_config),
                    .float_control(float_control),
                    .halt_req(halt_req),
                    .fpu_result_1(fpu_result_1),
                    .fpu_rounding(fpu_rounding),
                    .dec_i0_rs1_en_d(dec_i0_rs1_en_d),
                    .dec_i0_rs2_en_d(dec_i0_rs2_en_d),
                    .fpu_sel(fpu_sel)
                );

    Execution Excecution_Unit(
                            .clk(clk),
                            .rst_l(rst_l),
                            .RS1_d(RS1_d),
                            .RS2_d(RS2_d),
                            .result(result),
                            .Flag_ADDI(Flag_ADDI),
                            .Flag_LI(Flag_LI),
                            .Activation_Signal(Activation_Signal),
                            .Flag_Reset(Flag_Reset),
                            .fpu_active(fpu_active),
                            .illegal_config(illegal_config),
                            .valid_execution(valid_execution),
                            .fs1_data(fs1_data),
                            .fs2_data(fs2_data),
                            .fs3_data(fs3_data),
                            .sfpu_op(sfpu_op),
                            .fpu_pre(fpu_pre),
                            .fpu_rounding(fpu_rounding),
                            .float_control(float_control),
                            .fpu_result_1(fpu_result_1),
                            .S_flag(S_flag),
                            .dec_i0_rs1_en_d(dec_i0_rs1_en_d),
                            .dec_i0_rs2_en_d(dec_i0_rs2_en_d),
                            .IV_exception(IV_exception),
                            .fpu_complete(fpu_complete),
                            .fpu_sel(fpu_sel)
                            );

    Inst_check Inst_Checker(
              .clk(clk),
              .rst_l(rst_l),
              .inst_opcode(Instruction_out[6:0]),
              .fpu_complete(fpu_complete),
              .halt_req(halt_req),
              .stall_scalar(stall_scalar),
              .fpu_active(fpu_active)
              );

    initial 
    begin
        $dumpfile("FPU_FSM.vcd");
        $dumpvars(0);
    end

endmodule