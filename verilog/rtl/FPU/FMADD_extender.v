//module for extension 

module FMADD_Extender (Extender_input_A,Extender_input_B,Extender_output_A,Extender_output_B);
parameter std =31;
parameter man = 22;
parameter exp = 7;

//input declaration
input [std+1:0]  Extender_input_A,Extender_input_B;


//output declaration
output [2+exp+2*(man+2):0] Extender_output_A,Extender_output_B;

//main functionlity
assign  Extender_output_A =  {Extender_input_A[std+1],1'b0,Extender_input_A[std:0],{man+2{1'b0}}}  ;
assign  Extender_output_B =  {Extender_input_B[std+1],1'b0,Extender_input_B[std:0],{man+2{1'b0}}}  ;


endmodule