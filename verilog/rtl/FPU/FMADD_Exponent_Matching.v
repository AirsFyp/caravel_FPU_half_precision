//module is responsible for matching the exponents for addition

module FMADD_Exponent_Matching (Exponent_Matching_input_Sign_A,Exponent_Matching_input_Sign_B,Exponent_Matching_input_Exp_A,Exponent_Matching_input_Exp_B,Exponent_Matching_input_Mantissa_A,Exponent_Matching_input_Mantissa_B,Exponent_Matching_input_opcode,Exponent_Matching_output_Mantissa_A,Exponent_Matching_output_Mantissa_B,Exponent_Matching_output_Exp,Exponent_Matching_output_Guard,Exponent_Matching_output_Round,Exponent_Matching_output_Sticky,Exponent_Matching_output_Sign,Exponent_Matching_output_Eff_Sub,Exponent_Matching_output_Eff_add);

//defination of prameters
parameter std =31;
parameter man =22;
parameter exp =7;

//declaration of inptu port
input Exponent_Matching_input_Sign_A,Exponent_Matching_input_Sign_B;
input [exp:0] Exponent_Matching_input_Exp_A,Exponent_Matching_input_Exp_B;
input [man+man+3:0] Exponent_Matching_input_Mantissa_A,Exponent_Matching_input_Mantissa_B;

// opcode[0] = Fadd
// opcode[1] = Fsub
input [1:0] Exponent_Matching_input_opcode;

//declaration of putptu ports
output Exponent_Matching_output_Sign;
output [man+man+3:0] Exponent_Matching_output_Mantissa_A,Exponent_Matching_output_Mantissa_B;
output [exp:0] Exponent_Matching_output_Exp;
output Exponent_Matching_output_Guard,Exponent_Matching_output_Round,Exponent_Matching_output_Sticky,Exponent_Matching_output_Eff_Sub,Exponent_Matching_output_Eff_add;

//main funtionality 

//declaration for wires

wire Exponent_Matching_Bit_Exp_A_ge_B,Exponent_Matching_Bit_Exp_A_gt_B,Exponent_Matching_Bit_Exp_A_eq_B,Exponent_Matching_Bit_Man_a_ge_Man_B,Exponent_Matching_Bit_Eff_sub,Exponent_Matching_Bit_Eff_add;
wire [4*man+7:0] Exponent_Matching_Shifter_input,Exponent_Matching_Shifter_output;
wire [exp:0] Exponent_Matching_Exp_Sub_input_1 , Exponent_Matching_Exp_Sub_input_2;
wire [exp:0] Exponent_Matching_Shif_Amount;

//check for exp_A >= exp_B
assign Exponent_Matching_Bit_Exp_A_gt_B = Exponent_Matching_input_Exp_A > Exponent_Matching_input_Exp_B;
assign Exponent_Matching_Bit_Exp_A_eq_B = Exponent_Matching_input_Exp_A == Exponent_Matching_input_Exp_B;
assign Exponent_Matching_Bit_Exp_A_ge_B  = Exponent_Matching_Bit_Exp_A_gt_B | Exponent_Matching_Bit_Exp_A_eq_B;

//check for Manstissa _A >= Mantisa_B
assign Exponent_Matching_Bit_Man_a_ge_Man_B = Exponent_Matching_input_Mantissa_A >= Exponent_Matching_input_Mantissa_B;

//check for true subtraction or ture additions
assign Exponent_Matching_Bit_Eff_sub = ( ( Exponent_Matching_input_Sign_A ^ Exponent_Matching_input_Sign_B)  & ( Exponent_Matching_input_opcode[0] )  )  |  ( (~(Exponent_Matching_input_Sign_A ^ Exponent_Matching_input_Sign_B))  & ( Exponent_Matching_input_opcode[1] )  ); 
assign Exponent_Matching_output_Eff_Sub = Exponent_Matching_Bit_Eff_sub;
assign Exponent_Matching_Bit_Eff_add = ( ( Exponent_Matching_input_Sign_A ^ Exponent_Matching_input_Sign_B)  & ( Exponent_Matching_input_opcode[1] )  )  |  ( (~(Exponent_Matching_input_Sign_A ^ Exponent_Matching_input_Sign_B))  & ( Exponent_Matching_input_opcode[0] )  );
assign Exponent_Matching_output_Eff_add = Exponent_Matching_Bit_Eff_add;
//shifter circutrary input
assign Exponent_Matching_Shifter_input = ( Exponent_Matching_Bit_Exp_A_ge_B ) ? { Exponent_Matching_input_Mantissa_B , {(2*man)+4{1'b0}}}   :  { Exponent_Matching_input_Mantissa_A , {(2*man)+4{1'b0}}}  ;

//logic for determination of shift amount and slection of finalized exponent
assign Exponent_Matching_Exp_Sub_input_1 = ( Exponent_Matching_Bit_Exp_A_ge_B ) ? Exponent_Matching_input_Exp_A : Exponent_Matching_input_Exp_B; 
assign Exponent_Matching_Exp_Sub_input_2 = ( ~Exponent_Matching_Bit_Exp_A_ge_B ) ? Exponent_Matching_input_Exp_A : Exponent_Matching_input_Exp_B;      
assign Exponent_Matching_Shif_Amount = Exponent_Matching_Exp_Sub_input_1 -Exponent_Matching_Exp_Sub_input_2;

//shifting circutary
assign Exponent_Matching_Shifter_output  = Exponent_Matching_Shifter_input >> Exponent_Matching_Shif_Amount ;

//decision for sign of the Addition Lane's output
assign Exponent_Matching_output_Sign = ( Exponent_Matching_Bit_Eff_add | ( Exponent_Matching_Bit_Exp_A_gt_B & Exponent_Matching_Bit_Eff_sub )  | ( ( Exponent_Matching_Bit_Exp_A_eq_B & Exponent_Matching_Bit_Eff_sub ) & ( Exponent_Matching_Bit_Man_a_ge_Man_B ) )  ) ? Exponent_Matching_input_Sign_A : (( Exponent_Matching_input_opcode[1]) ? Exponent_Matching_input_Sign_B ^ Exponent_Matching_input_opcode[1] :  Exponent_Matching_input_Sign_B ^ 1'b0 ) ;

//decision fo MAntissa A for output
assign Exponent_Matching_output_Mantissa_A = (Exponent_Matching_Bit_Exp_A_ge_B) ? Exponent_Matching_input_Mantissa_A : Exponent_Matching_Shifter_output[4*man+7 : 2*man+4];
assign Exponent_Matching_output_Mantissa_B = (Exponent_Matching_Bit_Exp_A_ge_B) ? Exponent_Matching_Shifter_output[4*man+7 : 2*man+4] : Exponent_Matching_input_Mantissa_B;

//decision of xponent
assign Exponent_Matching_output_Exp = Exponent_Matching_Exp_Sub_input_1;

//decision fo rrounding bits
assign Exponent_Matching_output_Guard = Exponent_Matching_Shifter_output[man+man+3] ;
assign Exponent_Matching_output_Round = Exponent_Matching_Shifter_output[man+man+2] ;
assign Exponent_Matching_output_Sticky = (Exponent_Matching_Shif_Amount >= 96) ? 1'b1: (|Exponent_Matching_Shifter_output [man+man+1:0]) ;


endmodule