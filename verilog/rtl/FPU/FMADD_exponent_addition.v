//This module is responsisble for addition of exponents 

module FMADD_Exponent_addition (Exponent_addition_input_A,Exponent_addition_input_B,Exponent_addition_input_Activation_Signal,Exponent_addition_output_exp,Exponent_addition_output_sign,output_underflow_check);
parameter std=31;
parameter man =22;
parameter exp = 7;

//declaration of inputs
input [exp+1:0] Exponent_addition_input_A,Exponent_addition_input_B;
input Exponent_addition_input_Activation_Signal;

//declaration of putputs
output  [exp+1:0] Exponent_addition_output_exp;
output Exponent_addition_output_sign;
output output_underflow_check;
wire [exp+1:0] Exponent_addition_wire_exp;

//functionality 
assign Exponent_addition_wire_exp = (Exponent_addition_input_Activation_Signal) ? (Exponent_addition_input_A[exp:0] + Exponent_addition_input_B[exp:0]): {(exp+2){1'b0}};
assign output_underflow_check  = Exponent_addition_wire_exp < 103;
assign Exponent_addition_output_exp = Exponent_addition_wire_exp;
assign Exponent_addition_output_sign = (Exponent_addition_input_Activation_Signal) ? (Exponent_addition_input_A [exp+1] ^ Exponent_addition_input_B[exp+1]) : 1'b0;


endmodule
