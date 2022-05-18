// mantissa_mutliplication_nodule is resposible 

module FMADD_Mantissa_Multiplication (Mantissa_Multiplication_input_A,Mantissa_Multiplication_input_B,Mantissa_Multiplication_input_Activation_Signal,Mantissa_Multiplication_output_Mantissa);
parameter man = 22;
parameter exp = 7;

//declaration of inputs 
input [man+1:0] Mantissa_Multiplication_input_A,Mantissa_Multiplication_input_B;
input Mantissa_Multiplication_input_Activation_Signal;
//declaration 
output [man+man+3:0] Mantissa_Multiplication_output_Mantissa;

//main functionality
assign Mantissa_Multiplication_output_Mantissa = (Mantissa_Multiplication_input_Activation_Signal) ? Mantissa_Multiplication_input_A * Mantissa_Multiplication_input_B: {2{{2'b00, {man{1'b0}}}}};

endmodule
