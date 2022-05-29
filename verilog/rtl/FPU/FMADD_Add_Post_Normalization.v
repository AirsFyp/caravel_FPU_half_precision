 //this module is responsible fo rperdfiming the post normalization of the generted result from addition of mantissas
//`include "F_LZD_Main.v"

module FMADD_Post_Normalization_Add_Sub(Post_Normalization_input_Mantissa,Post_Normalization_input_exponent,Post_Normalization_input_Carry,Post_Normalization_input_Eff_sub,Post_Normalization_input_Eff_add,Post_Normalization_input_Guard,Post_Normalization_input_Round,Post_Normalization_input_Sticky,Post_Normalization_output_Guard,Post_Normalization_output_Round,Post_Normalization_output_Sticky,Post_Normalization_output_Mantissa,Post_Normalization_output_exponent );

//defination of parameters
parameter std = 31;
parameter man = 22;
parameter exp = 7;
parameter lzd = 4;

//declaration of putptu ports
input [man+man+3:0] Post_Normalization_input_Mantissa;
input [exp+1:0] Post_Normalization_input_exponent;
input Post_Normalization_input_Carry,Post_Normalization_input_Eff_sub,Post_Normalization_input_Eff_add,Post_Normalization_input_Guard,Post_Normalization_input_Round,Post_Normalization_input_Sticky;

//declaration of putptu ports
output [man + 1 :0] Post_Normalization_output_Mantissa;
output [exp+1:0] Post_Normalization_output_exponent;
output Post_Normalization_output_Guard,Post_Normalization_output_Round,Post_Normalization_output_Sticky;

//declaration of interim wires
wire [exp+1:0] Post_Normaliaation_Bit_Shamt_interim;
wire [exp+1:0] Post_Normaliaation_Bit_Shamt_1;
wire [23:0]   Post_Normaliaation_Bit_input_LZD;
wire [lzd:0]   Post_Normaliaation_Bit_output_LZD;
wire Post_Normaliaation_Bit_exp_LZD_Comp;
wire [exp+1:0] Post_Normaliaation_Bit_Shift_Amount;
wire [man+man+3:0] Post_Normalization_Shifter_Output_Sub,Post_Normalization_Shifter_Output_add,Post_Normalization_Shifter_input_add;
wire [man+man+3:0] Post_Normalization_Mantissa_interim_48;
wire [exp+1:0]   Post_Normaliaation_EFF_Sub_interim_Exponent;
wire [exp+1:0] Post_Normaliaation_EFF_add_interim_Exponent;

//Calculation of number of Zero concatinations in LZD's output
localparam  [2:0]  Post_Normalization_wire_Concatination_Amount = (man == 32'd22) ? 3'd4 : (exp == 32'd4) ? 3'd2 : (man == 32'd6 ) ? 3'd5 : 3'd0 ;

//instantition of LZD 
 FMADD_PN_LZD Lzd_PN_AD ( 
                   .FMADD_PN_LZD_input_man_48 ( Post_Normaliaation_Bit_input_LZD ), 
                   .FMADD_PN_LZD_output_pos   ( Post_Normaliaation_Bit_output_LZD) 
                   ) ;
 defparam Lzd_PN_AD.man = man;                  
 defparam Lzd_PN_AD.lzd = lzd;

//main functionality 

//subtraction lane 
assign Post_Normaliaation_Bit_Shamt_interim = Post_Normalization_input_exponent - 1'b1; 
assign Post_Normaliaation_Bit_Shamt_1 = (Post_Normalization_input_Eff_sub) ?  Post_Normaliaation_Bit_Shamt_interim : {exp+2{1'b0}};
assign Post_Normaliaation_Bit_input_LZD = (Post_Normalization_input_Eff_sub) ?  { { 24-(man+2){1'b0} },Post_Normalization_input_Mantissa[man+man+3:man+2]} : {man+2{1'b0}};
assign Post_Normaliaation_Bit_exp_LZD_Comp = Post_Normalization_input_exponent > Post_Normaliaation_Bit_output_LZD;
assign Post_Normaliaation_Bit_Shift_Amount = (Post_Normaliaation_Bit_exp_LZD_Comp) ?  {{Post_Normalization_wire_Concatination_Amount{1'b0}},Post_Normaliaation_Bit_output_LZD} : Post_Normaliaation_Bit_Shamt_1 ;
assign Post_Normalization_Shifter_Output_Sub  = Post_Normalization_input_Mantissa << Post_Normaliaation_Bit_Shift_Amount;
assign Post_Normaliaation_EFF_Sub_interim_Exponent = Post_Normalization_input_exponent - Post_Normaliaation_Bit_Shift_Amount ; 


//additio lanse
assign Post_Normaliaation_EFF_add_interim_Exponent = Post_Normalization_input_exponent + Post_Normalization_input_Carry ; 
assign Post_Normalization_Shifter_input_add = (Post_Normalization_input_Eff_add) ? Post_Normalization_input_Mantissa : {(man+man+4){1'b0}};
assign Post_Normalization_Shifter_Output_add = (Post_Normalization_input_Carry) ? { Post_Normalization_input_Carry,Post_Normalization_Shifter_input_add[man+man+3:1] } : Post_Normalization_Shifter_input_add[man+man+3:0]  ;

//Output Selestion and Round bits extarcion
assign Post_Normalization_Mantissa_interim_48 = (Post_Normalization_input_Eff_sub) ? Post_Normalization_Shifter_Output_Sub : Post_Normalization_Shifter_Output_add ; 

assign Post_Normalization_output_Mantissa = Post_Normalization_Mantissa_interim_48[man+man+3:man+2];
assign Post_Normalization_output_Round = Post_Normalization_Mantissa_interim_48[man] ;
assign Post_Normalization_output_Guard = Post_Normalization_Mantissa_interim_48[man+1];
assign Post_Normalization_output_Sticky = ( (|Post_Normalization_Mantissa_interim_48[man-1:0]) | Post_Normalization_input_Guard | Post_Normalization_input_Round | Post_Normalization_input_Sticky);
assign Post_Normalization_output_exponent = (Post_Normalization_input_Eff_sub) ? Post_Normaliaation_EFF_Sub_interim_Exponent : Post_Normaliaation_EFF_add_interim_Exponent;


endmodule

