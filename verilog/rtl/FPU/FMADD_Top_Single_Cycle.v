
// Designed by : ALi Raza Zaidi
//mains modue of FMADD 


//mains modue of FMADD 

/*//including coommon blocks

`include "FMADD_M_G.v"
`include "FMADD_Ext.v"
`include "F_LZD_Main.v"
`include "fma_LZD_L0.v"
`include "fma_LZD_L1.v"
`include "fma_LZD_L2.v"
`include "fma_LZD_L3.v"
`include "fma_LZD_L4.v"

//including Multiplication LANE
`include "FMADD_E_A.v"
`include "FMADD_mult.v"
`include "FMADD_PN_Mul.v"
`include "FMADD_RB_MUL.v"

//Includign Addition/Subtraction LANE
`include "FMADD_E_M.v"
`include "FMADD_M_A.v"
`include "FMADD_PN_Ad.v"
`include "FMADD_RB_Ad.v"*/



//including coommon blocks
/*
`include "FMADD_mantissa_generator.v"
`include "FMADD_extender.v"
`include "fma_LZD.v"
`include "fma_LZD_L0.v"
`include "fma_LZD_L1.v"
`include "fma_LZD_L2.v"
`include "fma_LZD_L3.v"
`include "fma_LZD_L4.v"

//including Multiplication LANE
`include "FMADD_exponent_addition.v"
`include "FMADD_mantissa_multiplication.v"
`include "FMADD_mul_post_normalization.v"
`include "FMADD_mul_rounding_block.v"

//Includign Addition/Subtraction LANE
`include "FMADD_exponent_matching.v"
`include "FMADD_mantissa_addition.v"
`include "FMADD_add_post_normalization.v"
`include "FMADD_add_rounding_Block.v"
*/

module FPU_FMADD_SUBB_Top (FMADD_SUBB_input_IEEE_A, FMADD_SUBB_input_IEEE_B, FMADD_SUBB_input_IEEE_C, FMADD_SUBB_input_opcode,rst_l,FMADD_SUBB_input_Frm,FMADD_SUBB_output_IEEE_FMADD, FMADD_SUBB_output_S_Flags_FMADD, FMADD_SUBB_output_IEEE_FMUL, FMADD_SUBB_output_S_Flags_FMUL );

parameter std =31;
parameter man =22;
parameter exp = 7;
parameter bias = 127;
parameter lzd = 4;

//declaration of inputs
input  [std:0] FMADD_SUBB_input_IEEE_A, FMADD_SUBB_input_IEEE_B,FMADD_SUBB_input_IEEE_C;
input [6:0] FMADD_SUBB_input_opcode;
input [2:0] FMADD_SUBB_input_Frm;
input rst_l;

//Opcodes description
/*
Opcodes[0] = Fadd
Opcodes[1] = Fsubb
Opcodes[2] = Fmul
Opcodes[3] = Fmadd
Opcodes[4] = Fmsubb
Opcodes[5] = Fnmadd
Opcodes[6] = Fnmsubb
*/

//declaration of putputs
output  [std:0] FMADD_SUBB_output_IEEE_FMADD, FMADD_SUBB_output_IEEE_FMUL;
output  [2:0] FMADD_SUBB_output_S_Flags_FMADD , FMADD_SUBB_output_S_Flags_FMUL;
//output FMADD_SUBB_output_FMADD_Ready_Flag;

//instantiation of sub modules
//mantissa generation modules: This module concatenates the hidden bit, and sets the exponent in accordance with the type of number (Normal Sub_Normal)

//activation isgnal for multiplication lane
wire Activation_signal_MUL,Activation_signal;
wire [std:0] input_interim_Mantissa_gnerator_A,input_interim_Mantissa_gnerator_B,input_interim_Mantissa_gnerator_C;
wire [std+1:0] output_interim_M_G_A,output_interim_M_G_B,output_interim_M_G_C;
wire output_interim_A_sub_norm,output_interim_B_sub_norm,output_interim_A_pos_exp,output_interim_B_pos_exp,output_interim_A_neg_exp,output_interim_B_neg_exp;


//Reset condition
assign input_interim_Mantissa_gnerator_A = (rst_l)  ? FMADD_SUBB_input_IEEE_A : { std+1 {1'b0} };
assign input_interim_Mantissa_gnerator_B = (rst_l)  ? FMADD_SUBB_input_IEEE_B : { std+1 {1'b0} };
assign input_interim_Mantissa_gnerator_C = (rst_l)  ? FMADD_SUBB_input_IEEE_C : { std+1 {1'b0} };
assign Activation_signal_MUL = (rst_l) ? ( |(FMADD_SUBB_input_opcode[6:2]) ) : 1'b0;
assign Activation_signal = (rst_l) ? ( | (FMADD_SUBB_input_opcode[6:0])) : 1'b0;

FMADD_Mantissa_Generator Mantissa_Generator ( 
                        .Mantissa_Generator_input_IEEE_A (input_interim_Mantissa_gnerator_A),
                        .Mantissa_Generator_input_IEEE_B (input_interim_Mantissa_gnerator_B),
                        .Mantissa_Generator_input_IEEE_C (input_interim_Mantissa_gnerator_C),
                        .Mantissa_Generator_input_Activation_signal (Activation_signal),
                        .Mantissa_Generator_output_A_Sub_norm(output_interim_A_sub_norm),
                        .Mantissa_Generator_output_B_Sub_norm(output_interim_B_sub_norm),
                        .Mantissa_Generator_output_A_pos_exp(output_interim_A_pos_exp),
                        .Mantissa_Generator_output_B_pos_exp(output_interim_B_pos_exp),
                        .Mantissa_Generator_output_A_neg_exp(output_interim_A_neg_exp),
                        .Mantissa_Generator_output_B_neg_exp(output_interim_B_neg_exp),
                        .Mantissa_Generator_output_IEEE_A (output_interim_M_G_A),
                        .Mantissa_Generator_output_IEEE_B (output_interim_M_G_B),
                        .Mantissa_Generator_output_IEEE_C (output_interim_M_G_C)
 );
defparam Mantissa_Generator.std = std;
defparam Mantissa_Generator.man = man;
defparam Mantissa_Generator.exp = exp;

//extend  module : This module is responsible for making the input representable in IEEE exteded format
wire [std+1 : 0] input_Extender_B;
wire [1+exp+2*(man+2):0] output_interim_Extender_A,output_interim_Extender_B;

//selection of the second operand of the extender : If addition is the inputted instruction B goes to extender otherwise C goes to the Extender
assign input_Extender_B = (| FMADD_SUBB_input_opcode[1:0]) ? output_interim_M_G_B : output_interim_M_G_C;
FMADD_Extender Extender (
              .Extender_input_A(output_interim_M_G_A),
              .Extender_input_B(input_Extender_B),
              .Extender_output_A(output_interim_Extender_A),
              .Extender_output_B(output_interim_Extender_B)
);
defparam Extender.std = std;
defparam Extender.man = man;
defparam Extender.exp = exp;

//exponent addition module: This module is repsonsible for carrying out tje first operation of Multiplication i.e.e exponent addition
wire [4:0] input_interim_exponent_addition_opcodes;
wire input_Exponent_Addition_input_Sign_A;
wire [exp+1 : 0] output_interim_exponent_addition;
wire output_interim_exponent_addition_sign;
wire underflow_FMUL;

assign input_Exponent_Addition_input_Sign_A = ( |FMADD_SUBB_input_opcode[6:5] ) ? (~output_interim_M_G_A[std+1]) : (output_interim_M_G_A[std+1]) ;

FMADD_Exponent_addition Exponent_Addition (
                       .Exponent_addition_input_A({ input_Exponent_Addition_input_Sign_A, output_interim_M_G_A[std:man+2] } ),
                       .Exponent_addition_input_B(output_interim_M_G_B[std+1:man+2]),
                       .Exponent_addition_input_Activation_Signal (Activation_signal_MUL),
                       .Exponent_addition_output_exp(output_interim_exponent_addition),
                       .output_underflow_check (underflow_FMUL),
                       .Exponent_addition_output_sign(output_interim_exponent_addition_sign)
);
defparam Exponent_Addition.std = std;
defparam Exponent_Addition.man = man;
defparam Exponent_Addition.exp = exp;


//mantissa multiplication Module
wire [man+man+3 :0] output_interim_mantissa_multiplication;

FMADD_Mantissa_Multiplication Mantissa_Multiplication ( 
                             .Mantissa_Multiplication_input_A(output_interim_M_G_A[man+1:0]),
                             .Mantissa_Multiplication_input_B(output_interim_M_G_B[man+1:0]),
                             .Mantissa_Multiplication_input_Activation_Signal (Activation_signal_MUL),
                             .Mantissa_Multiplication_output_Mantissa( output_interim_mantissa_multiplication) 
);
defparam Mantissa_Multiplication.man = man;
defparam Mantissa_Multiplication.exp = exp;

//instantiation of LZD module
wire [23:0] input_LZD;
wire [lzd : 0] output_interim_LZD, output_interim_1_LZD;

assign input_LZD = (output_interim_A_sub_norm) ? output_interim_M_G_A[man+1:0] : output_interim_M_G_B[man+1:0] ;


FMADD_PN_LZD Leading_Zero_detection (
                  .FMADD_PN_LZD_input_man_48(input_LZD), 
                  .FMADD_PN_LZD_output_pos(output_interim_LZD)
);

//5'b1100 == 2;s compliment of 8, 8 is subtracted from the final result since the LZD is of 32 bit and actual data is of 24 bit.                  
//assign to_add_in_lzd_mul = (output_interim_LZD + 5'b11000);
assign output_interim_1_LZD = output_interim_LZD ;


//post normalaization Module
wire [1+exp+2*(man+2):0] output_interim_post_normalization_IEEE;
wire output_interim_post_normalization_mul_overflow_flag, output_interim_post_normalization_mul_sticky;

FMADD_PN_MUL Post_Normalization_Mul ( 
                  . FMADD_PN_MUL_input_sign (output_interim_exponent_addition_sign),  
                  . FMADD_PN_MUL_input_multiplied_man (output_interim_mantissa_multiplication),
                  . FMADD_PN_MUL_input_exp_DB (output_interim_exponent_addition),
                  . FMADD_PN_MUL_input_lzd (output_interim_1_LZD),
                  . FMADD_PN_MUL_input_A_sub  (output_interim_A_sub_norm),
                  . FMADD_PN_MUL_input_B_sub  (output_interim_B_sub_norm),
                  . FMADD_PN_MUL_input_A_pos  (output_interim_A_pos_exp),
                  . FMADD_PN_MUL_input_B_pos  (output_interim_B_pos_exp),
                  . FMADD_PN_MUL_input_A_neg  (output_interim_A_neg_exp),
                  . FMADD_PN_MUL_input_B_neg  (output_interim_B_neg_exp),
                  . FMADD_PN_MUL_output_no (output_interim_post_normalization_IEEE),
                  . FMADD_PN_MUL_output_overflow (output_interim_post_normalization_mul_overflow_flag), 
                  . FMADD_PN_MUL_output_sticky_PN(output_interim_post_normalization_mul_sticky),
                  . FMADD_PN_MUL_input_rm(FMADD_SUBB_input_Frm)
);

defparam Post_Normalization_Mul.std = std;
defparam Post_Normalization_Mul.exp = exp;
defparam Post_Normalization_Mul.man = man;
defparam Post_Normalization_Mul.bias = bias;
defparam Post_Normalization_Mul.lzd = lzd;

//module instantiatyion of Rounding Block of Multipliction Lane
wire [std:0] output_rounding_Block;
wire [2:0] output_interim_rounding_Block_S_Flag;

FMADD_ROUND_MUL Rounding_Block_Mul (
                     .FMADD_ROUND_MUL_input_overflow(output_interim_post_normalization_mul_overflow_flag),
                     .FMADD_ROUND_MUL_input_sticky_PN(output_interim_post_normalization_mul_sticky),
                     .FMADD_ROUND_MUL_input_no(output_interim_post_normalization_IEEE),
                     .FMADD_ROUND_MUL_input_rm(FMADD_SUBB_input_Frm),
                     .FMADD_ROUND_MUL_output_no(output_rounding_Block),
                     .FMADD_ROUND_MUL_output_S_Flags(output_interim_rounding_Block_S_Flag)
);
defparam Rounding_Block_Mul.std = std;
defparam Rounding_Block_Mul.exp = exp;
defparam Rounding_Block_Mul.man = man;

//module instantiation of FMADD Lane
///=interim wires and register for FMADD Lane

//ppelining registers
wire [1+exp+2*(man+2):0] input_interim_ADD_LANE_A;
wire [1+exp+2*(man+2):0] input_interim_ADD_LANE_B;

//inputs to the FMADD LANE
assign input_interim_ADD_LANE_A = ( |(FMADD_SUBB_input_opcode[1:0] ) ) ? output_interim_Extender_A : (| FMADD_SUBB_input_opcode[6:3]) ? output_interim_post_normalization_IEEE : 57'h000000000000000 ;
assign input_interim_ADD_LANE_B =  (|(FMADD_SUBB_input_opcode[1:0] ) ) ? output_interim_Extender_B : (| FMADD_SUBB_input_opcode[6:3]) ? output_interim_Extender_B : 57'h000000000000000;

//exponent_Matching
wire output_interim_Exponent_Mathcing_Sign;
wire [man+man+3:0] output_interim_Exponent_Mathcing_Mantissa_A;
wire [man+man+3:0] output_interim_Exponent_Mathcing_Mantissa_B;
wire [exp:0] output_interim_Exponent_Mathcing_Exponent;
wire output_interim_Exponent_Mathcing_Eff_add;
wire output_interim_Exponent_Mathcing_Eff_sub;
wire output_interim_Exponent_Mathcing_Guard;
wire output_interim_Exponent_Mathcing_Round;
wire output_interim_Exponent_Mathcing_Sticky;



FMADD_Exponent_Matching Exponent_Matching ( 
                            .Exponent_Matching_input_Sign_A ( input_interim_ADD_LANE_A[1+exp+2*(man+2)] ),
                            .Exponent_Matching_input_Sign_B(  input_interim_ADD_LANE_B[1+exp+2*(man+2)]  ),
                            .Exponent_Matching_input_Exp_A(  input_interim_ADD_LANE_A[exp+2*(man+2): man+man+4] ),
                            .Exponent_Matching_input_Exp_B( input_interim_ADD_LANE_B[exp+2*(man+2): man+man+4]  ),
                            .Exponent_Matching_input_Mantissa_A( input_interim_ADD_LANE_A[man+man+3 : 0] ),
                            .Exponent_Matching_input_Mantissa_B( input_interim_ADD_LANE_B[man+man+3 : 0] ),
                            .Exponent_Matching_input_opcode( {  FMADD_SUBB_input_opcode[1] | FMADD_SUBB_input_opcode[4] | FMADD_SUBB_input_opcode[6] , FMADD_SUBB_input_opcode[0] | FMADD_SUBB_input_opcode[5] | FMADD_SUBB_input_opcode[3]}  ),
                            .Exponent_Matching_output_Mantissa_A( output_interim_Exponent_Mathcing_Mantissa_A),
                            .Exponent_Matching_output_Mantissa_B( output_interim_Exponent_Mathcing_Mantissa_B),
                            .Exponent_Matching_output_Exp (output_interim_Exponent_Mathcing_Exponent),
                            .Exponent_Matching_output_Sign( output_interim_Exponent_Mathcing_Sign),
                            .Exponent_Matching_output_Guard (output_interim_Exponent_Mathcing_Guard),
                            .Exponent_Matching_output_Round( output_interim_Exponent_Mathcing_Round),
                            .Exponent_Matching_output_Sticky( output_interim_Exponent_Mathcing_Sticky),
                            .Exponent_Matching_output_Eff_Sub( output_interim_Exponent_Mathcing_Eff_sub),
                            .Exponent_Matching_output_Eff_add( output_interim_Exponent_Mathcing_Eff_add)
  );
defparam Exponent_Matching.std = std;
defparam Exponent_Matching.exp = exp;
defparam Exponent_Matching.man = man;


//Mantissa Addition
wire [man+man+3:0] output_interim_Mantissa_Addition_Mantissa;
wire output_interim_Mantissa_Addition_Carry;
FMADD_Mantissa_Addition Mantissa_Addition (
                             .Mantissa_Addition_input_Mantissa_A( output_interim_Exponent_Mathcing_Mantissa_A),
                             .Mantissa_Addition_input_Mantissa_B( output_interim_Exponent_Mathcing_Mantissa_B),
                             .Mantissa_Addition_input_Eff_Sub( output_interim_Exponent_Mathcing_Eff_sub),
                             .Mantissa_Addition_output_Mantissa(output_interim_Mantissa_Addition_Mantissa ), 
                             .Mantissa_Addition_output_Carry(output_interim_Mantissa_Addition_Carry)
);
defparam Mantissa_Addition.std = std;
defparam Mantissa_Addition.exp = exp; 
defparam Mantissa_Addition.man = man;

//Post Normalization Module
wire output_interim_Post_Norm_Add_Guard;
wire output_interim_Post_Norm_Add_Round;
wire output_interim_Post_Norm_Add_Sticky;
wire [exp+1:0] output_interim_Post_Norm_Add_Exponent;
wire [man+1:0] output_interim_Post_Norm_Add_Mantissa;
FMADD_Post_Normalization_Add_Sub Post_Normalization_Add (
                                .Post_Normalization_input_Mantissa ( output_interim_Mantissa_Addition_Mantissa ),
                                .Post_Normalization_input_exponent ( output_interim_Exponent_Mathcing_Exponent),
                                .Post_Normalization_input_Carry ( output_interim_Mantissa_Addition_Carry),
                                .Post_Normalization_input_Eff_sub ( output_interim_Exponent_Mathcing_Eff_sub ),
                                .Post_Normalization_input_Eff_add ( output_interim_Exponent_Mathcing_Eff_add),
                                .Post_Normalization_input_Guard ( output_interim_Exponent_Mathcing_Guard),
                                .Post_Normalization_input_Round ( output_interim_Exponent_Mathcing_Round),
                                .Post_Normalization_input_Sticky ( output_interim_Exponent_Mathcing_Sticky ),
                                .Post_Normalization_output_Guard ( output_interim_Post_Norm_Add_Guard),
                                .Post_Normalization_output_Round (output_interim_Post_Norm_Add_Round),
                                .Post_Normalization_output_Sticky ( output_interim_Post_Norm_Add_Sticky),
                                .Post_Normalization_output_Mantissa ( output_interim_Post_Norm_Add_Mantissa ),
                                .Post_Normalization_output_exponent ( output_interim_Post_Norm_Add_Exponent)
);
defparam Post_Normalization_Add.std = std;
defparam Post_Normalization_Add.exp = exp;
defparam Post_Normalization_Add.man = man;

//Rounding Mode Module
wire [exp:0] output_interim_Rounding_Block_Exp;
wire [man:0] output_interim_Rounding_Block_Mantissa;
wire  output_interim_Rounding_Block_Sign;
wire [1:0] output_interim_Rounding_Block_S_flags;
wire [2:0] input_rounding_block_Add_frm;

assign input_rounding_block_Add_frm =   (|FMADD_SUBB_input_opcode[6:3] | (|FMADD_SUBB_input_opcode[1:0]) ) ? FMADD_SUBB_input_Frm : 3'b000;

FMADD_Roudning_Block_Addition Rounding_Block_Add (
                           .Rounding_Block_input_Mantissa (output_interim_Post_Norm_Add_Mantissa) ,
                           .Rounding_Block_input_Exponent (output_interim_Post_Norm_Add_Exponent),
                           .Rounding_Block_input_Sign (output_interim_Exponent_Mathcing_Sign),
                           .Rounding_Block_input_Guard (output_interim_Post_Norm_Add_Guard),
                           .Rounding_Block_input_Round (output_interim_Post_Norm_Add_Round),
                           .Rounding_Block_input_Sticky (output_interim_Post_Norm_Add_Sticky),
                           .Rounding_Block_input_Frm (input_rounding_block_Add_frm),
                           .Rounding_Block_output_Exponent (output_interim_Rounding_Block_Exp),
                           .Rounding_Block_output_Sign ( output_interim_Rounding_Block_Sign),
                           .Rounding_Block_output_Mantissa( output_interim_Rounding_Block_Mantissa ),
                           .Rounding_Block_output_S_Flags (output_interim_Rounding_Block_S_flags)
);
defparam Rounding_Block_Add.std = std;
defparam Rounding_Block_Add.exp = exp;
defparam Rounding_Block_Add.man = man;

//Multiplication lane output ports
assign  FMADD_SUBB_output_IEEE_FMUL = ( (~FMADD_SUBB_input_opcode[2]) | (~rst_l) ) ?  { std+1 {1'b0} } : output_rounding_Block ;
assign  FMADD_SUBB_output_S_Flags_FMUL = (  ( FMADD_SUBB_input_opcode[2] ) & (rst_l)  ) ? output_interim_rounding_Block_S_Flag : 3'b000;

//addition Lane output POrts
assign FMADD_SUBB_output_IEEE_FMADD = (  ((|FMADD_SUBB_input_opcode[1:0]) | (|FMADD_SUBB_input_opcode[6:3]) ) & (rst_l) ) ? { output_interim_Rounding_Block_Sign, output_interim_Rounding_Block_Exp ,output_interim_Rounding_Block_Mantissa } :{ std+1 {1'b0} } ;
assign FMADD_SUBB_output_S_Flags_FMADD = ( ( (|FMADD_SUBB_input_opcode[1:0]) | (|FMADD_SUBB_input_opcode[6:3]) ) & (rst_l)  ) ? {output_interim_Rounding_Block_S_flags[1],1'b0,output_interim_Rounding_Block_S_flags[0]} : 3'b00;


endmodule
