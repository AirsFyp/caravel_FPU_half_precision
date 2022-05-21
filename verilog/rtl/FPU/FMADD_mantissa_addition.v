//mantissa addition module


module  FMADD_Mantissa_Addition( Mantissa_Addition_input_Mantissa_A,Mantissa_Addition_input_Mantissa_B,Mantissa_Addition_input_Eff_Sub,Mantissa_Addition_output_Mantissa, Mantissa_Addition_output_Carry,Mantissa_Addition_input_Exp_Diff_Check );

//declaration of paramters
parameter std =31;
parameter man = 22;
parameter exp = 7;

//declaration of input ports
input [man+man+3:0] Mantissa_Addition_input_Mantissa_A,Mantissa_Addition_input_Mantissa_B;
input Mantissa_Addition_input_Eff_Sub;
input Mantissa_Addition_input_Exp_Diff_Check;

/*
opcode[0]= fadd;    
opcode[1] = Fsuub
*/


wire [man+man+3:0] interim_mantissa_B,interim_mantissa_B_adder;
wire Mantissa_Addition_interim_Carry;
wire [man+man+3:0] Mantissa_Addition_Compliment_B;

//declartion of output piorts
output Mantissa_Addition_output_Carry;
output [man+man+3:0] Mantissa_Addition_output_Mantissa;


//Main functionality
assign Mantissa_Addition_Compliment_B = ( (~(Mantissa_Addition_input_Mantissa_B)) + (~Mantissa_Addition_input_Exp_Diff_Check)  );

assign interim_mantissa_B = (Mantissa_Addition_input_Eff_Sub) ? Mantissa_Addition_Compliment_B : Mantissa_Addition_input_Mantissa_B ;
assign {Mantissa_Addition_interim_Carry,interim_mantissa_B_adder} = {1'b0, interim_mantissa_B} + {1'b0,Mantissa_Addition_input_Mantissa_A};

assign Mantissa_Addition_output_Mantissa = ( (~Mantissa_Addition_interim_Carry) & Mantissa_Addition_input_Eff_Sub ) ? ( ~(interim_mantissa_B_adder) + (~Mantissa_Addition_input_Exp_Diff_Check) ) : interim_mantissa_B_adder;
assign Mantissa_Addition_output_Carry = Mantissa_Addition_interim_Carry;



endmodule
