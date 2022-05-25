//mantissa addition module


module  FMADD_Mantissa_Addition( Mantissa_Addition_input_Mantissa_A,Mantissa_Addition_input_Mantissa_B,Mantissa_Addition_input_Eff_Sub,Mantissa_Addition_output_Mantissa, Mantissa_Addition_output_Carry,Mantissa_Addition_input_Exp_Diff_Check,Mantissa_Addition_input_A_gt_B );

//declaration of paramters
parameter std =31;
parameter man = 22;
parameter exp = 7;

//declaration of input ports
input [man+man+3:0] Mantissa_Addition_input_Mantissa_A,Mantissa_Addition_input_Mantissa_B;
input Mantissa_Addition_input_Eff_Sub;
input Mantissa_Addition_input_Exp_Diff_Check, Mantissa_Addition_input_A_gt_B;

/*
opcode[0]= fadd;    
opcode[1] = Fsuub
*/


wire [man+man+3:0] interim_mantissa_B_adder;
wire Mantissa_Addition_interim_Carry,Mantissa_Addition_interim_Compliment_Carry;
wire [man+man+3:0] Mantissa_Addition_Compliment_B,Mantissa_Addition_Compliment_1_Factor;
wire [man+man+3:0] Mantissa_Addition_Compliment_Lane_input,Mantissa_Addition_Adder_Lane_input_A,Mantissa_Addition_Adder_Lane_input_B;
wire Mantissa_Addition_Compliment_Addend;


//declartion of output piorts
output Mantissa_Addition_output_Carry;
output [man+man+3:0] Mantissa_Addition_output_Mantissa;


//Main functionality

//decision of two operands for the final adders
assign Mantissa_Addition_Compliment_Lane_input = (Mantissa_Addition_input_A_gt_B) ? Mantissa_Addition_input_Mantissa_B : Mantissa_Addition_input_Mantissa_A;
assign Mantissa_Addition_Adder_Lane_input_A = (Mantissa_Addition_input_A_gt_B) ? Mantissa_Addition_input_Mantissa_A : Mantissa_Addition_input_Mantissa_B;

//compliment of the Smaller operand of the two
assign Mantissa_Addition_Compliment_Addend = (~Mantissa_Addition_input_Exp_Diff_Check);
assign Mantissa_Addition_Compliment_1_Factor = (~Mantissa_Addition_Compliment_Lane_input);
assign {Mantissa_Addition_interim_Compliment_Carry,Mantissa_Addition_Compliment_B} = ( {1'b0,Mantissa_Addition_Compliment_1_Factor} + {1'b0,Mantissa_Addition_Compliment_Addend}  );

//Opernad two of the Adder lane
assign Mantissa_Addition_Adder_Lane_input_B = (Mantissa_Addition_input_Eff_Sub) ? Mantissa_Addition_Compliment_B : Mantissa_Addition_Compliment_Lane_input ;


assign {Mantissa_Addition_interim_Carry,interim_mantissa_B_adder} = {1'b0, Mantissa_Addition_Adder_Lane_input_A} + {1'b0,Mantissa_Addition_Adder_Lane_input_B};


assign Mantissa_Addition_output_Mantissa = ( (~Mantissa_Addition_interim_Carry) & Mantissa_Addition_input_Eff_Sub & (~Mantissa_Addition_interim_Compliment_Carry) ) ? ( ~(interim_mantissa_B_adder) + (Mantissa_Addition_Compliment_Addend) ) : interim_mantissa_B_adder;
assign Mantissa_Addition_output_Carry = Mantissa_Addition_interim_Carry;



endmodule
