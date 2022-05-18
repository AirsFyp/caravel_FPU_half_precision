`include "fma_LZD.v"

module FMADD_PN_MUL( FMADD_PN_MUL_input_sign, FMADD_PN_MUL_input_exp_DB, FMADD_PN_MUL_input_multiplied_man, FMADD_PN_MUL_input_lzd, FMADD_PN_MUL_input_rm, FMADD_PN_MUL_input_A_neg, FMADD_PN_MUL_input_A_pos, FMADD_PN_MUL_input_A_sub, FMADD_PN_MUL_input_B_neg, FMADD_PN_MUL_input_B_pos, FMADD_PN_MUL_input_B_sub, FMADD_PN_MUL_output_no, FMADD_PN_MUL_output_overflow, FMADD_PN_MUL_output_sticky_PN);

initial
begin
	$dumpfile("dump.vcd");
	$dumpvars(0);
end

//Defining Parameters
parameter std = 31;//Standard - 1
parameter man = 22;//mantissa bits -1
parameter exp = 7;//Exp bits -1
parameter bias = 127;//Bias for selected standard
parameter lzd = 4;

input FMADD_PN_MUL_input_A_neg, FMADD_PN_MUL_input_A_pos, FMADD_PN_MUL_input_A_sub, FMADD_PN_MUL_input_B_neg, FMADD_PN_MUL_input_B_pos, FMADD_PN_MUL_input_B_sub;
input FMADD_PN_MUL_input_sign;
input [exp+1 : 0]FMADD_PN_MUL_input_exp_DB;
input [man+man+3 : 0]FMADD_PN_MUL_input_multiplied_man;
input [lzd : 0]FMADD_PN_MUL_input_lzd;
input [2 : 0]FMADD_PN_MUL_input_rm;


output [man+man+exp+5 : 0]FMADD_PN_MUL_output_no;//57 bit output having sign, 8bit exp and 48bit mantissa
output FMADD_PN_MUL_output_overflow;
output FMADD_PN_MUL_output_sticky_PN;

wire [lzd : 0]FMADD_PN_MUL_input_lzd_shifts = FMADD_PN_MUL_input_lzd + 1'b1; 

wire FMADD_PN_MUL_wire_op_1, FMADD_PN_MUL_wire_op_2, FMADD_PN_MUL_wire_op_3, FMADD_PN_MUL_wire_op_4, FMADD_PN_MUL_wire_op_5;
wire [exp+1 : 0]FMADD_PN_MUL_wire_127_sub_expDB_extra_bit, FMADD_PN_MUL_wire_expDB_sub_127_extra_bit;
wire [exp : 0] FMADD_PN_MUL_wire_exp_shifts_interim;
wire [lzd+1 : 0]FMADD_PN_MUL_wire_exp_shifts;
wire FMADD_PN_MUL_wire_condition_2;
wire [lzd+1 : 0]FMADD_PN_MUL_wire_shifts_lzd_msb;
wire [4 : 0] FMADD_PN_MUL_wire_output_LZD;
wire FMADD_PN_MUL_wire_condition_3;
wire [exp : 0]FMADD_PN_MUL_wire_shifts_interim;
wire [31 : 0]FMADD_PN_MUL_wire_useless;
wire FMADD_PN_MUL_wire_shifts_overflow;
wire [lzd+1 : 0]FMADD_PN_MUL_wire_shifts_final;
wire FMADD_PN_MUL_wire_exp_eq_127, FMADD_PN_MUL_wire_exp_gt_127, FMADD_PN_MUL_wire_exp_lt_127, PM_MUL_wire_sub_or_norm_op5;
wire FMADD_PN_LZD_wire_direction_shifts;
wire [man+man+3 : 0]FMADD_PN_MUL_wire_DTRS, FMADD_PN_MUL_wire_DTLS;
wire [man+man+4 : 0]FMADD_PN_MUL_wire_RS_data, FMADD_PN_MUL_wire_LS_data;
wire [man+man+4 : 0]FMADD_PN_MUL_wire_man_interim;
wire [man+man+3 : 0]FMADD_PN_MUL_wire_man_final;


wire FMADD_PN_MUL_wire_condition_5;
wire [31 : 0]FMADD_PN_MUL_wire_zero_useless;
wire [exp+1 : 0]FMADD_PN_MUL_wire_exp_interim_1;
wire FMADD_PN_MUL_wire_condition_6;
wire [exp+1 : 0]FMADD_PN_MUL_wire_exp_interim_2;
wire [exp+1 : 0]FMADD_PN_MUL_wire_exp_interim_3;
wire FMADD_PN_MUL_wire_condition_7;
wire [4 : 0]FMADD_PN_MUL_wire_lzd_true;
wire [4 : 0]FMADD_PN_MUL_wire_lzd_true_sub_49;
wire [exp+1 : 0]FMADD_PN_MUL_wire_exp_interim_4;
wire [exp+1 : 0]FMADD_PN_MUL_wire_exp_interim_5;

wire FMADD_PN_MUL_wire_exception_cond1;
wire [man+man+exp+5 : 0]FMADD_PN_MUL_wire_output_interim_1;
wire FMADD_PN_MUL_wire_exception_cond2;


assign FMADD_PN_MUL_wire_op_1 = (FMADD_PN_MUL_input_A_pos) & (FMADD_PN_MUL_input_B_pos) ;
assign FMADD_PN_MUL_wire_op_2 = (FMADD_PN_MUL_input_A_neg) & (FMADD_PN_MUL_input_B_pos) | (FMADD_PN_MUL_input_A_pos) & (FMADD_PN_MUL_input_B_neg) ;
assign FMADD_PN_MUL_wire_op_3 = (FMADD_PN_MUL_input_A_pos) & (FMADD_PN_MUL_input_B_sub) | (FMADD_PN_MUL_input_A_sub) & (FMADD_PN_MUL_input_B_pos) ;
assign FMADD_PN_MUL_wire_op_4 = (FMADD_PN_MUL_input_A_neg) & (FMADD_PN_MUL_input_B_sub) | (FMADD_PN_MUL_input_A_sub) & (FMADD_PN_MUL_input_B_neg) ;
assign FMADD_PN_MUL_wire_op_5 = (FMADD_PN_MUL_input_A_neg) & (FMADD_PN_MUL_input_B_neg);

//both wires are 9 bit(extra bit) since the DB exponent is of 9 bits
assign FMADD_PN_MUL_wire_127_sub_expDB_extra_bit = bias[exp+1:0] - FMADD_PN_MUL_input_exp_DB;
assign FMADD_PN_MUL_wire_expDB_sub_127_extra_bit = FMADD_PN_MUL_input_exp_DB - bias[exp+1:0];



assign FMADD_PN_MUL_wire_exp_shifts_interim = FMADD_PN_MUL_wire_op_3 ? (FMADD_PN_MUL_wire_expDB_sub_127_extra_bit[exp : 0]) : (FMADD_PN_MUL_wire_127_sub_expDB_extra_bit[exp : 0]);

//man+man+4 is first stored here since man is a parameter and parameters are 32 bit wide so using parameter directly will raise a mismatch error.
assign FMADD_PN_MUL_wire_useless = man+man+4;
assign FMADD_PN_MUL_wire_shifts_overflow = (FMADD_PN_MUL_wire_exp_shifts_interim > man+man+4) | (FMADD_PN_MUL_input_A_sub & FMADD_PN_MUL_input_B_sub);
//If shifts are greater than 48 then set then to 48.
assign FMADD_PN_MUL_wire_exp_shifts = (FMADD_PN_MUL_wire_shifts_overflow) ? (FMADD_PN_MUL_wire_useless[(lzd+1) : 0]) : (FMADD_PN_MUL_wire_exp_shifts_interim[(lzd+1) : 0]) ; 

assign FMADD_PN_MUL_wire_condition_2 = FMADD_PN_MUL_wire_op_3 & (!(FMADD_PN_MUL_input_lzd_shifts > FMADD_PN_MUL_wire_expDB_sub_127_extra_bit));
assign FMADD_PN_MUL_wire_shifts_lzd_msb = FMADD_PN_MUL_wire_condition_2 ? ({1'b0,FMADD_PN_MUL_input_lzd_shifts}) : { ({(lzd+1){1'b0}}) , (!FMADD_PN_MUL_input_multiplied_man[man+man+3])} ;

//Condition using which value of shift will be decided
assign FMADD_PN_MUL_wire_condition_3 = FMADD_PN_MUL_wire_condition_2 | FMADD_PN_MUL_wire_op_1 | FMADD_PN_MUL_wire_op_2 | (FMADD_PN_MUL_wire_op_5 & (!PM_MUL_wire_sub_or_norm_op5));
//Deciding which value of shift to select
assign FMADD_PN_MUL_wire_shifts_final = FMADD_PN_MUL_wire_condition_3 ? FMADD_PN_MUL_wire_shifts_lzd_msb : FMADD_PN_MUL_wire_exp_shifts ;

assign FMADD_PN_MUL_wire_exp_eq_127 = FMADD_PN_MUL_input_exp_DB == bias;
assign FMADD_PN_MUL_wire_exp_gt_127 = FMADD_PN_MUL_input_exp_DB >  bias;
assign FMADD_PN_MUL_wire_exp_lt_127 = FMADD_PN_MUL_input_exp_DB <  bias;

//PM_MUL_wire_sub_or_norm_op5 == 1 when subnormal results from multiplication of -ve exp with subnormal
assign PM_MUL_wire_sub_or_norm_op5 = 
(!FMADD_PN_MUL_input_multiplied_man[man+man+3]) & (!FMADD_PN_MUL_wire_exp_eq_127) & (!FMADD_PN_MUL_wire_exp_gt_127) & ( FMADD_PN_MUL_wire_exp_lt_127) |
(!FMADD_PN_MUL_input_multiplied_man[man+man+3]) & ( FMADD_PN_MUL_wire_exp_eq_127) & (!FMADD_PN_MUL_wire_exp_gt_127) & (!FMADD_PN_MUL_wire_exp_lt_127) |
( FMADD_PN_MUL_input_multiplied_man[man+man+3]) & (!FMADD_PN_MUL_wire_exp_eq_127) & (!FMADD_PN_MUL_wire_exp_gt_127) & ( FMADD_PN_MUL_wire_exp_lt_127) ;

//Direction == 1 when right shifts are to be done and 0 when left shifts are to be done
//Direction of shifts is also to the right in case both the numbers are subnormal
assign FMADD_PN_LZD_wire_direction_shifts = (FMADD_PN_MUL_wire_op_5 & PM_MUL_wire_sub_or_norm_op5) | FMADD_PN_MUL_wire_op_4 | (FMADD_PN_MUL_input_A_sub & FMADD_PN_MUL_input_B_sub);

//DTRS = Data To Right Shift
assign FMADD_PN_MUL_wire_DTRS =  FMADD_PN_LZD_wire_direction_shifts ? FMADD_PN_MUL_input_multiplied_man : 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 ;
//DTLS = Data To Left Shift
assign FMADD_PN_MUL_wire_DTLS =  FMADD_PN_LZD_wire_direction_shifts ? 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 : FMADD_PN_MUL_input_multiplied_man ;

//RS == Right Shifted
assign FMADD_PN_MUL_wire_RS_data = ({1'b0, FMADD_PN_MUL_wire_DTRS}) >> FMADD_PN_MUL_wire_shifts_final;
//LS == Left Shifted
assign FMADD_PN_MUL_wire_LS_data = ({1'b0, FMADD_PN_MUL_wire_DTLS}) << FMADD_PN_MUL_wire_shifts_final;

assign FMADD_PN_MUL_wire_man_interim =  FMADD_PN_LZD_wire_direction_shifts ? FMADD_PN_MUL_wire_RS_data : FMADD_PN_MUL_wire_LS_data ;

assign FMADD_PN_MUL_wire_man_final = (FMADD_PN_MUL_wire_man_interim[man+man+4]) ? FMADD_PN_MUL_wire_man_interim[man+man+4 : 1] : FMADD_PN_MUL_wire_man_interim[man+man+3 : 0];

//Exponent Logic


assign FMADD_PN_MUL_wire_condition_5 = FMADD_PN_MUL_wire_op_4 | (FMADD_PN_MUL_wire_op_5 & PM_MUL_wire_sub_or_norm_op5) | (FMADD_PN_MUL_wire_op_3 & (FMADD_PN_MUL_input_lzd_shifts > FMADD_PN_MUL_wire_expDB_sub_127_extra_bit)) | (FMADD_PN_MUL_input_A_sub & FMADD_PN_MUL_input_B_sub) ;

// Zero is first stored here since exponent size of different standards is different and using one specific size for FMADD_PN_MUL_wire_exp_interim_1 will raise a mismatch error.
assign FMADD_PN_MUL_wire_zero_useless = 0;
assign FMADD_PN_MUL_wire_exp_interim_1 = FMADD_PN_MUL_wire_condition_5 ? ({(exp+2){1'b0}}) : (FMADD_PN_MUL_wire_expDB_sub_127_extra_bit) ;

assign FMADD_PN_MUL_wire_condition_6 = FMADD_PN_MUL_wire_op_1 | FMADD_PN_MUL_wire_op_2 | (FMADD_PN_MUL_wire_op_5 & (!PM_MUL_wire_sub_or_norm_op5));
assign FMADD_PN_MUL_wire_exp_interim_2 = FMADD_PN_MUL_wire_exp_interim_1 + FMADD_PN_MUL_input_multiplied_man[man+man+3];
assign FMADD_PN_MUL_wire_exp_interim_3 = FMADD_PN_MUL_wire_condition_6 ? FMADD_PN_MUL_wire_exp_interim_2 : FMADD_PN_MUL_wire_exp_interim_1 ;

assign FMADD_PN_MUL_wire_condition_7 = FMADD_PN_MUL_wire_condition_2;
assign FMADD_PN_MUL_wire_lzd_true = FMADD_PN_MUL_input_lzd_shifts - 5'b0_0001;
assign FMADD_PN_MUL_wire_lzd_true_sub_49 = (FMADD_PN_MUL_wire_lzd_true - FMADD_PN_MUL_wire_man_interim[man+man+4]);
assign FMADD_PN_MUL_wire_exp_interim_4 = FMADD_PN_MUL_wire_exp_interim_3 - FMADD_PN_MUL_wire_lzd_true_sub_49;

assign FMADD_PN_MUL_wire_exp_interim_5 = FMADD_PN_MUL_wire_condition_7 ? FMADD_PN_MUL_wire_exp_interim_4 : FMADD_PN_MUL_wire_exp_interim_3 ;

//Selection of what exception to output in case of overflow, max normal number or infinity

assign FMADD_PN_MUL_wire_exception_cond1 = (FMADD_PN_MUL_input_rm == 3'b000 | FMADD_PN_MUL_input_rm == 3'b100) | ((!FMADD_PN_MUL_input_sign) & (FMADD_PN_MUL_input_rm == 3'b011)) | ((FMADD_PN_MUL_input_sign) & (FMADD_PN_MUL_input_rm == 3'b010));
assign FMADD_PN_MUL_wire_output_interim_1 = (FMADD_PN_MUL_wire_exception_cond1) ? ({ FMADD_PN_MUL_input_sign, ({exp+1{1'b1}}), ({man+man+4{1'b0}}) }) : ({ FMADD_PN_MUL_input_sign, ({{exp{1'b1}}, 1'b0}), ({man+man+4{1'b1}}) });
//condition to select output, either exception or result from main, in case 9th bit (singke precision) of exp is high or bits from 8:0 are high then it is overflow
assign FMADD_PN_MUL_wire_exception_cond2 = FMADD_PN_MUL_wire_exp_interim_5[exp+1] | (&FMADD_PN_MUL_wire_exp_interim_5[exp : 0]);
//Selecting what to output exception or result coming form main
assign FMADD_PN_MUL_output_no = (FMADD_PN_MUL_wire_exception_cond2) ? (FMADD_PN_MUL_wire_output_interim_1) : ({FMADD_PN_MUL_input_sign, (FMADD_PN_MUL_wire_exp_interim_5[exp : 0]), FMADD_PN_MUL_wire_man_final}) ;
//In case cond2 is high overflow flag is set to one
assign FMADD_PN_MUL_output_overflow = FMADD_PN_MUL_wire_exception_cond2;

//in case shifts are greater than M+N or subnormal numbers are getting multiplied with each other then sticky_PN will get high.
assign FMADD_PN_MUL_output_sticky_PN = FMADD_PN_MUL_wire_shifts_overflow;

endmodule