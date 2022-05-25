//Created for modular testing of intgeration in SwerV Core
//synchorunus input validation 
//Created by Ali Raza





module FPU_Input_Validation (rst_l,INPUT_VALIDATION_input_ieee_A,INPUT_VALIDATION_input_ieee_B,INPUT_VALIDATION_input_ieee_C,INPUT_VALIDATION_input_opcode,INPUT_VALIDATION_Output_temp_storage,INPUT_VALIDATION_Output_exception_flag_Fadd,INPUT_VALIDATION_Output_exception_flag_Fsub,INPUT_VALIDATION_Output_exception_flag_Fmul,INPUT_VALIDATION_Output_exception_flag_Fdiv,INPUT_VALIDATION_Output_exception_flag_Fsqrt,INPUT_VALIDATION_Output_exception_flag_Fcomp,INPUT_VALIDATION_Output_exception_flag_Fmadd,INPUT_VALIDATION_Output_exception_flag_Fmsub,INPUT_VALIDATION_Output_invalid_flag,INPUT_VALIDATION_Output_Flag_DZ,interupt_Pin);

parameter std=31;
parameter man= 22;
parameter exp=7;
parameter bias=8'b01111111;


/*opcode ctivation signals

sfpu[0] = Fadd
sfpu[1] = Fsubb
sfpu[2] = Fmul
sfpu[3] = Fdiv
sfpu[4] = Fsqrt
sfpu[5] = Fmin
sfpu[6] = Fmax
sfpu[7] = Fmvx
sfpu[8] = Fmvf
sfpu[9] = feq
sfpu[10] = flt
sfpu[11] = fle
sfpu[12] = Fmadd
sfpu[13] = Fmsubb
sfpu[14] = FCVT.W.P
sfpu[15] = FCVT.P.W
sfpu[16] = Fnmsubb
sfpu[17] = Fnmadd
sfpu[18] = fsgnj
sfpu[19] = fsgnjn
sfpu[20] = fsgnjx
sfpu[21] = fclass
sfpu[22] = unsign
sfpu[23] = sign
*/



input [std:0] INPUT_VALIDATION_input_ieee_A;
input [std:0] INPUT_VALIDATION_input_ieee_B;
input [std:0] INPUT_VALIDATION_input_ieee_C;
input [23:0]  INPUT_VALIDATION_input_opcode;
input rst_l;

//respective generted exception output 
output [std:0] INPUT_VALIDATION_Output_temp_storage;

//Flags

//exception flag to handle the termination of further execution in case any exceptional input occur
output INPUT_VALIDATION_Output_exception_flag_Fadd,INPUT_VALIDATION_Output_exception_flag_Fsub,INPUT_VALIDATION_Output_exception_flag_Fmul,INPUT_VALIDATION_Output_exception_flag_Fdiv,INPUT_VALIDATION_Output_exception_flag_Fsqrt,INPUT_VALIDATION_Output_exception_flag_Fcomp,INPUT_VALIDATION_Output_exception_flag_Fmadd,INPUT_VALIDATION_Output_exception_flag_Fmsub;

// Invalid flag
output  INPUT_VALIDATION_Output_invalid_flag;

// Divided By zero flag
output  INPUT_VALIDATION_Output_Flag_DZ;

//interupt pin
output interupt_Pin;

//interim register for holding few bolean conditions
wire  INPUT_VALIDATION_Bit_A_infinity;
wire INPUT_VALIDATION_Bit_B_infinity;
wire  INPUT_VALIDATION_Bit_C_infinity;
wire  INPUT_VALIDATION_Bit_A_SNAN;
wire INPUT_VALIDATION_Bit_B_SNAN;
wire  INPUT_VALIDATION_Bit_C_SNAN;
wire  INPUT_VALIDATION_Bit_A_QNAN;
wire INPUT_VALIDATION_Bit_B_QNAN;
wire  INPUT_VALIDATION_Bit_C_QNAN;
wire INPUT_VALIDATION_Bit_NAN;

wire  INPUT_VALIDATION_Mantissa_Zero_A;
wire  INPUT_VALIDATION_Mantissa_Zero_B;
wire  INPUT_VALIDATION_Mantissa_Zero_C;

wire  INPUT_VALIDATION_exp_One_A;
wire  INPUT_VALIDATION_exp_One_B;
wire  INPUT_VALIDATION_exp_One_C;

wire  INPUT_VALIDATION_Bit_A_zero;
wire  INPUT_VALIDATION_Bit_B_zero;
wire  INPUT_VALIDATION_Bit_C_zero;
wire  INPUT_VALIDATION_Bit_A_1;
wire  INPUT_VALIDATION_Bit_B_1;
wire  INPUT_VALIDATION_Bit_C_1;
wire  INPUT_VALIDATION_Bit_Equal;
wire  INPUT_VALIDATION_Bit_single_infinity;
wire  INPUT_VALIDATION_Bit_double_infinity;
wire  INPUT_VALIDATION_Bit_single_SNAN;
wire  INPUT_VALIDATION_Bit_single_QNAN;
wire  INPUT_VALIDATION_Bit_single_zero;
wire  INPUT_VALIDATION_Bit_double_zero;
wire  INPUT_VALIDATION_Bit_xor_sign_input_A;
wire  INPUT_VALIDATION_Bit_xor_sign;



//outptu selection bits
wire INPUT_VALIDATION_Bit_SNAN_Caught;
wire INPUT_VALIDATION_Bit_No_Comp_A_Caught;
wire INPUT_VALIDATION_Bit_Positive_No_Comp_A_Caught;
wire INPUT_VALIDATION_Bit_Negative_No_Comp_A_Caught;
wire INPUT_VALIDATION_Bit_No_Comp_B_Caught;
wire INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught;
wire INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught;
wire INPUT_VALIDATION_Bit_No_Comp_C_Caught;
wire INPUT_VALIDATION_Bit_Positive_No_Comp_C_Caught;
wire INPUT_VALIDATION_Bit_Negative_No_Comp_C_Caught;
wire INPUT_VALIDATION_Bit_Positive_infinity_Caught;
wire INPUT_VALIDATION_Bit_negative_infinity_Caught;
wire INPUT_VALIDATION_Bit_positive_zero_Caught;
wire INPUT_VALIDATION_Bit_negative_zero_Caught;
wire INPUT_VALIDATION_Bit_Negative_One_Caught;
wire INPUT_VALIDATION_Bit_Positive_One_Caught;

//Fadd wires
wire  INPUT_VALIDATION_Bit_SNAN_Caught_Fadd;
wire  INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fadd;
wire  INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fadd;
wire  INPUT_VALIDATION_Bit_positive_infinity_Caught_Fadd;
wire  INPUT_VALIDATION_Bit_negitive_infinity_Caught_Fadd;
wire  INPUT_VALIDATION_Bit_positive_zero_Caught_Fadd;
wire  INPUT_VALIDATION_Bit_negitive_zero_Caught_Fadd;

//Fsubb wires
wire  INPUT_VALIDATION_Bit_SNAN_Caught_Fsubb;
wire  INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fsubb;
wire  INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught_Fsubb;
wire  INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught_Fsubb;
wire  INPUT_VALIDATION_Bit_negitive_infinity_Caught_Fsubb;
wire  INPUT_VALIDATION_Bit_positive_zero_Caught_Fsubb;
wire  INPUT_VALIDATION_Bit_negitive_zero_Caught_Fsubb;

//Fmul wires
wire  INPUT_VALIDATION_Bit_SNAN_Caught_Fmul;
wire  INPUT_VALIDATION_Bit_positive_infinity_Caught_Fmul;
wire  INPUT_VALIDATION_Bit_negative_infinity_Caught_Fmul;
wire  INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmul;
wire  INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmul;
wire  INPUT_VALIDATION_Bit_negative_zero_Caught_Fmul;
wire  INPUT_VALIDATION_Bit_positive_zero_Caught_Fmul;

//Fdiv wires
wire  INPUT_VALIDATION_Bit_SNAN_Caught_Fdiv;
wire  INPUT_VALIDATION_Bit_positive_zero_Caught_Fdiv;
wire  INPUT_VALIDATION_Bit_negative_zero_Caught_Fdiv;
wire  INPUT_VALIDATION_Bit_positive_infinity_Caught_Fdiv;
wire  INPUT_VALIDATION_Bit_negative_infinity_Caught_Fdiv;
wire  INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fdiv;
wire  INPUT_VALIDATION_Bit_Positive_One_Caught_Fdiv;
wire  INPUT_VALIDATION_Bit_Negative_One_Caught_Fdiv;

//Fsqrt Wires
wire  INPUT_VALIDATION_Bit_SNAN_Caught_Fsqrt;
wire  INPUT_VALIDATION_Bit_zero_Caught_Fsqrt;
wire  INPUT_VALIDATION_Bit_positive_infinity_Caught_Fsqrt;
wire  INPUT_VALIDATION_Bit_Positive_One_Caught_Fsqrt;

//Fmin Wires 
wire INPUT_VALIDATION_Bit_SNAN_Caught_Fmin;
wire INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmin;
wire INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmin;

//Fmax Wires 
wire INPUT_VALIDATION_Bit_SNAN_Caught_Fmax;
wire INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmax;
wire INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmax;

//Flt wires
wire  INPUT_VALIDATION_Bit_zero_Caught_Flt;

//Fle wires
wire  INPUT_VALIDATION_Bit_zero_Caught_Fle;

//Feq wires
wire  INPUT_VALIDATION_Bit_zero_Caught_Feq;

//Fmadd wires
wire  INPUT_VALIDATION_Bit_SNAN_Caught_Fmadd;
wire  INPUT_VALIDATION_Bit_Positive_Zero_Caught_Fmadd;
wire  INPUT_VALIDATION_Bit_negative_Zero_Caught_Fmadd;
wire  INPUT_VALIDATION_Bit_positive_infinity_Caught_Fmadd;
wire  INPUT_VALIDATION_Bit_negative_infinity_Caught_Fmadd;
wire  INPUT_VALIDATION_Bit_Positive_No_Comp_A_Caught_Fmadd;
wire  INPUT_VALIDATION_Bit_Negative_No_Comp_A_Caught_Fmadd;
wire  INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught_Fmadd;
wire  INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught_Fmadd;
wire  INPUT_VALIDATION_Bit_No_Comp_C_Caught_Fmadd;

//Fmsubb wires
wire  INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb;
wire  INPUT_VALIDATION_Bit_Positive_Zero_Caught_Fmsubb ;
wire  INPUT_VALIDATION_Bit_Negative_Zero_Caught_Fmsubb;
wire  INPUT_VALIDATION_Bit_positive_infinity_Caught_Fmsubb;
wire  INPUT_VALIDATION_Bit_negative_infinity_Caught_Fmsubb;
wire  INPUT_VALIDATION_Bit_Positive_No_Comp_A_Caught_Fmsubb;
wire  INPUT_VALIDATION_Bit_Negative_No_Comp_A_Caught_Fmsubb;
wire  INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught_Fmsubb;
wire  INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught_Fmsubb;
wire  INPUT_VALIDATION_Bit_Positive_No_Comp_C_Caught_Fmsubb;
wire  INPUT_VALIDATION_Bit_Negative_No_Comp_C_Caught_Fmsubb;

    //check for 0 mantissa
	assign INPUT_VALIDATION_Mantissa_Zero_A =  ( & ( ~INPUT_VALIDATION_input_ieee_A[man:0] ));
    assign INPUT_VALIDATION_Mantissa_Zero_B =  ( & ( ~INPUT_VALIDATION_input_ieee_B[man:0] ));
	assign INPUT_VALIDATION_Mantissa_Zero_C =  ( & ( ~INPUT_VALIDATION_input_ieee_C[man:0] ));

    //check for all one exponent
    assign INPUT_VALIDATION_exp_One_A = ( & INPUT_VALIDATION_input_ieee_A[std-1:man+1] );
	assign INPUT_VALIDATION_exp_One_B = ( & INPUT_VALIDATION_input_ieee_B[std-1:man+1] );
    assign INPUT_VALIDATION_exp_One_C = ( & INPUT_VALIDATION_input_ieee_C[std-1:man+1] );

	//Bolean checks for XOR of sign
	assign INPUT_VALIDATION_Bit_xor_sign_input_A = (INPUT_VALIDATION_input_opcode[16] | INPUT_VALIDATION_input_opcode[17]) ? (~INPUT_VALIDATION_input_ieee_A[std]) : INPUT_VALIDATION_input_ieee_A[std];
	assign INPUT_VALIDATION_Bit_xor_sign = INPUT_VALIDATION_Bit_xor_sign_input_A ^ INPUT_VALIDATION_input_ieee_B[std] ;
	

	//Bolean check for checkin wather or not a spcific operand is infinity
	assign INPUT_VALIDATION_Bit_A_infinity = ( INPUT_VALIDATION_exp_One_A & INPUT_VALIDATION_Mantissa_Zero_A );

	assign INPUT_VALIDATION_Bit_B_infinity = ( INPUT_VALIDATION_exp_One_B & INPUT_VALIDATION_Mantissa_Zero_B );

	assign INPUT_VALIDATION_Bit_C_infinity = ( INPUT_VALIDATION_exp_One_C & INPUT_VALIDATION_Mantissa_Zero_C );

	//Boolean variables for detecting wether or not a single operand in the ijsntrustion is QNAN or not
	assign   INPUT_VALIDATION_Bit_A_QNAN = ( INPUT_VALIDATION_exp_One_A & ( INPUT_VALIDATION_input_ieee_A[man] ) );

	assign   INPUT_VALIDATION_Bit_B_QNAN = ( INPUT_VALIDATION_exp_One_B & ( INPUT_VALIDATION_input_ieee_B[man] ) );

	assign   INPUT_VALIDATION_Bit_C_QNAN = ( INPUT_VALIDATION_exp_One_C & ( INPUT_VALIDATION_input_ieee_C[man] ) );
	
	//Bolean variables for checking weateher or not the either of incoming operands is SNAN
	assign   INPUT_VALIDATION_Bit_A_SNAN = (  INPUT_VALIDATION_exp_One_A & ( ~( INPUT_VALIDATION_input_ieee_A[man] ) & ( |INPUT_VALIDATION_input_ieee_A[man-1:0] ) ) );

	assign   INPUT_VALIDATION_Bit_B_SNAN = (  INPUT_VALIDATION_exp_One_B & ( ~( INPUT_VALIDATION_input_ieee_B[man] ) & ( |INPUT_VALIDATION_input_ieee_B[man-1:0] ) ) ); 
    
	assign   INPUT_VALIDATION_Bit_C_SNAN = (  INPUT_VALIDATION_exp_One_C & ( ~( INPUT_VALIDATION_input_ieee_C[man] ) & ( |INPUT_VALIDATION_input_ieee_C[man-1:0] ) ) );
    
	assign INPUT_VALIDATION_Bit_NAN = INPUT_VALIDATION_Bit_A_SNAN | INPUT_VALIDATION_Bit_B_SNAN | INPUT_VALIDATION_Bit_A_QNAN | INPUT_VALIDATION_Bit_B_QNAN; 

	//Bolean check sfor checking weather or not a spcific operand is zero
	assign INPUT_VALIDATION_Bit_A_zero = (&(~INPUT_VALIDATION_input_ieee_A[std-1:man+1])) & (INPUT_VALIDATION_Mantissa_Zero_A);
	assign INPUT_VALIDATION_Bit_B_zero = (&(~INPUT_VALIDATION_input_ieee_B[std-1:man+1])) & (INPUT_VALIDATION_Mantissa_Zero_B);
	assign INPUT_VALIDATION_Bit_C_zero = (&(~INPUT_VALIDATION_input_ieee_C[std-1:man+1])) & (INPUT_VALIDATION_Mantissa_Zero_C);

	//Bolean checks for cheking watehr or not a spcific operand is 1
	assign INPUT_VALIDATION_Bit_A_1 = ((INPUT_VALIDATION_input_ieee_A[std-1:man+1]==bias) && INPUT_VALIDATION_Mantissa_Zero_A);
	assign INPUT_VALIDATION_Bit_B_1 =  ((INPUT_VALIDATION_input_ieee_B[std-1:man+1]==bias) && INPUT_VALIDATION_Mantissa_Zero_B);
	assign INPUT_VALIDATION_Bit_C_1 =  ((INPUT_VALIDATION_input_ieee_C[std-1:man+1]==bias) && INPUT_VALIDATION_Mantissa_Zero_C);

	// Check for quality of two numbers
	assign INPUT_VALIDATION_Bit_Equal = ( INPUT_VALIDATION_input_ieee_A [std-1:0] == INPUT_VALIDATION_input_ieee_B[std-1:0] );
	
	
	//Bolean checks for checking weather two or one or three operands are related to a specific exception (such as single infinity means one of the two opernds inputed are ininfiyt)
	
	//check for number of infinity pernds 
	assign INPUT_VALIDATION_Bit_single_infinity = (INPUT_VALIDATION_Bit_A_infinity) || (INPUT_VALIDATION_Bit_B_infinity);
	assign INPUT_VALIDATION_Bit_double_infinity = (INPUT_VALIDATION_Bit_A_infinity) && (INPUT_VALIDATION_Bit_B_infinity);
	
	

	//check for number of zero pernds
	assign INPUT_VALIDATION_Bit_single_zero = (INPUT_VALIDATION_Bit_A_zero) || (INPUT_VALIDATION_Bit_B_zero);
	assign INPUT_VALIDATION_Bit_double_zero = (INPUT_VALIDATION_Bit_A_zero) && (INPUT_VALIDATION_Bit_B_zero);
	
//Bolean check for indication of type of exceptions occured (as a function of input)

// Fadd Exceptional casses
assign INPUT_VALIDATION_Bit_SNAN_Caught_Fadd = ( INPUT_VALIDATION_input_opcode[0]  & ( INPUT_VALIDATION_Bit_NAN | ( INPUT_VALIDATION_Bit_double_infinity & INPUT_VALIDATION_Bit_xor_sign ) ) ) ;   

assign INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fadd = ( INPUT_VALIDATION_input_opcode[0]  & ( (INPUT_VALIDATION_Bit_B_zero & ~INPUT_VALIDATION_Bit_double_zero) | (INPUT_VALIDATION_Bit_A_infinity &  (~INPUT_VALIDATION_Bit_double_infinity) )  )  ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fadd);   

assign INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fadd = ( INPUT_VALIDATION_input_opcode[0]  & ( (INPUT_VALIDATION_Bit_A_zero & ~INPUT_VALIDATION_Bit_double_zero) | (INPUT_VALIDATION_Bit_B_infinity & (~INPUT_VALIDATION_Bit_double_infinity) )  )   ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fadd);   

assign INPUT_VALIDATION_Bit_positive_infinity_Caught_Fadd =  ( INPUT_VALIDATION_input_opcode[0] & ( INPUT_VALIDATION_Bit_double_infinity & (~INPUT_VALIDATION_input_ieee_A[std] & ~INPUT_VALIDATION_input_ieee_B[std]) ) ) ;

assign INPUT_VALIDATION_Bit_negitive_infinity_Caught_Fadd =  ( INPUT_VALIDATION_input_opcode[0] & ( INPUT_VALIDATION_Bit_double_infinity & (INPUT_VALIDATION_input_ieee_A[std] & INPUT_VALIDATION_input_ieee_B[std]) ) );   

assign INPUT_VALIDATION_Bit_positive_zero_Caught_Fadd = (INPUT_VALIDATION_input_opcode[0] & (INPUT_VALIDATION_Bit_double_zero & ( (~INPUT_VALIDATION_input_ieee_A[std]) & (~INPUT_VALIDATION_input_ieee_B[std]) ) ) )  ;   

assign INPUT_VALIDATION_Bit_negitive_zero_Caught_Fadd = (INPUT_VALIDATION_input_opcode[0] & (INPUT_VALIDATION_Bit_double_zero & ( INPUT_VALIDATION_Bit_xor_sign ) ) ) ;

//          Exception flag of fadd made high here
assign INPUT_VALIDATION_Output_exception_flag_Fadd =  INPUT_VALIDATION_Bit_SNAN_Caught_Fadd | INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fadd | INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fadd | INPUT_VALIDATION_Bit_positive_infinity_Caught_Fadd | INPUT_VALIDATION_Bit_negitive_infinity_Caught_Fadd | INPUT_VALIDATION_Bit_positive_zero_Caught_Fadd |  INPUT_VALIDATION_Bit_negitive_zero_Caught_Fadd;

//Fsub exceptionl cases
assign INPUT_VALIDATION_Bit_SNAN_Caught_Fsubb = ( INPUT_VALIDATION_input_opcode[1]  & (INPUT_VALIDATION_Bit_NAN | ( INPUT_VALIDATION_Bit_double_infinity & (~INPUT_VALIDATION_Bit_xor_sign) ) ) ) ;

assign INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fsubb = ( INPUT_VALIDATION_input_opcode[1] & ( (INPUT_VALIDATION_Bit_B_zero & (~INPUT_VALIDATION_Bit_double_zero) ) | (INPUT_VALIDATION_Bit_A_infinity & (~INPUT_VALIDATION_Bit_double_infinity) )  ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fsubb);

assign INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught_Fsubb = ( (INPUT_VALIDATION_input_opcode[1] & INPUT_VALIDATION_input_ieee_B[std] )  & ( (INPUT_VALIDATION_Bit_A_zero & (~INPUT_VALIDATION_Bit_double_zero) ) | (INPUT_VALIDATION_Bit_B_infinity & (~INPUT_VALIDATION_Bit_double_infinity) )  ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fsubb); // sign of this operand in th resultant will be checked based on the sign of this operand: 0 -(-B) = B hnce thisis dealed seperately in output selection logic

assign INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught_Fsubb = ( (INPUT_VALIDATION_input_opcode[1] & (~INPUT_VALIDATION_input_ieee_B[std]) )  & ( (INPUT_VALIDATION_Bit_A_zero & (~INPUT_VALIDATION_Bit_double_zero) ) | (INPUT_VALIDATION_Bit_B_infinity & (~INPUT_VALIDATION_Bit_double_infinity) )  ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fsubb);

assign INPUT_VALIDATION_Bit_negitive_infinity_Caught_Fsubb =  ( INPUT_VALIDATION_input_opcode[1] & ( INPUT_VALIDATION_Bit_double_infinity & (INPUT_VALIDATION_Bit_xor_sign) ) );  //the resulting infinicty in this case would be a negative infinity

assign INPUT_VALIDATION_Bit_positive_zero_Caught_Fsubb = (INPUT_VALIDATION_input_opcode[1] & ( (INPUT_VALIDATION_Bit_Equal) | ( ( (~INPUT_VALIDATION_input_ieee_A[std]) | (INPUT_VALIDATION_input_ieee_A[std] & (INPUT_VALIDATION_input_ieee_B[std]) ) ) & INPUT_VALIDATION_Bit_double_zero) )  ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fsubb);

assign INPUT_VALIDATION_Bit_negitive_zero_Caught_Fsubb = (INPUT_VALIDATION_input_opcode[1] & (INPUT_VALIDATION_Bit_double_zero & (INPUT_VALIDATION_input_ieee_A[std] & (~INPUT_VALIDATION_input_ieee_B[std])) ) );

//        Exeption Flag for Fsub 
assign INPUT_VALIDATION_Output_exception_flag_Fsub = INPUT_VALIDATION_Bit_SNAN_Caught_Fsubb | INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fsubb | INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught_Fsubb | INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught_Fsubb | INPUT_VALIDATION_Bit_negitive_infinity_Caught_Fsubb | INPUT_VALIDATION_Bit_positive_zero_Caught_Fsubb | INPUT_VALIDATION_Bit_negitive_zero_Caught_Fsubb;

//Fmul exceptional casses
assign INPUT_VALIDATION_Bit_SNAN_Caught_Fmul = ( INPUT_VALIDATION_input_opcode[2] & ( INPUT_VALIDATION_Bit_NAN |  (INPUT_VALIDATION_Bit_single_zero & INPUT_VALIDATION_Bit_single_infinity) )  );

assign INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmul = ( INPUT_VALIDATION_input_opcode[2] & ( INPUT_VALIDATION_Bit_B_1 )  )  & (~INPUT_VALIDATION_Bit_A_zero) & (~INPUT_VALIDATION_Bit_A_infinity) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmul) ;

assign INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmul = ( INPUT_VALIDATION_input_opcode[2] & ( INPUT_VALIDATION_Bit_A_1 )  )  & (~INPUT_VALIDATION_Bit_B_zero) & (~INPUT_VALIDATION_Bit_B_infinity) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmul) & (~INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmul) ;

assign INPUT_VALIDATION_Bit_positive_infinity_Caught_Fmul =  ( INPUT_VALIDATION_input_opcode[2] & ( INPUT_VALIDATION_Bit_single_infinity & (~INPUT_VALIDATION_Bit_xor_sign) ) )  & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmul);

assign INPUT_VALIDATION_Bit_negative_infinity_Caught_Fmul =  ( INPUT_VALIDATION_input_opcode[2] & ( INPUT_VALIDATION_Bit_single_infinity & (INPUT_VALIDATION_Bit_xor_sign) ) )  & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmul);

assign INPUT_VALIDATION_Bit_positive_zero_Caught_Fmul = ( INPUT_VALIDATION_input_opcode[2] & (INPUT_VALIDATION_Bit_single_zero & (~INPUT_VALIDATION_Bit_xor_sign) )  )  & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmul);

assign INPUT_VALIDATION_Bit_negative_zero_Caught_Fmul = ( INPUT_VALIDATION_input_opcode[2] & ( (INPUT_VALIDATION_Bit_single_zero & (INPUT_VALIDATION_Bit_xor_sign) ) ))  & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmul);

//     exception Flag for Fmul
assign INPUT_VALIDATION_Output_exception_flag_Fmul = INPUT_VALIDATION_Bit_SNAN_Caught_Fmul | INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmul | INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmul | INPUT_VALIDATION_Bit_positive_infinity_Caught_Fmul | INPUT_VALIDATION_Bit_negative_infinity_Caught_Fmul | INPUT_VALIDATION_Bit_positive_zero_Caught_Fmul | INPUT_VALIDATION_Bit_negative_zero_Caught_Fmul ;


//Fdiv cases
assign  INPUT_VALIDATION_Bit_SNAN_Caught_Fdiv = (INPUT_VALIDATION_input_opcode[3] & ( ( INPUT_VALIDATION_Bit_NAN ) | ( INPUT_VALIDATION_Bit_double_infinity ) | (INPUT_VALIDATION_Bit_double_zero ) )  );

assign INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fdiv = ( INPUT_VALIDATION_input_opcode[3] & ( INPUT_VALIDATION_Bit_B_1 )  & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fdiv)) & (~INPUT_VALIDATION_Bit_Positive_One_Caught_Fdiv) & (~INPUT_VALIDATION_Bit_Negative_One_Caught_Fdiv);

assign INPUT_VALIDATION_Bit_Positive_One_Caught_Fdiv = ( INPUT_VALIDATION_input_opcode[3] & ( INPUT_VALIDATION_Bit_Equal ) & (~INPUT_VALIDATION_Bit_xor_sign) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fdiv) ;

assign INPUT_VALIDATION_Bit_Negative_One_Caught_Fdiv = ( INPUT_VALIDATION_input_opcode[3] & ( INPUT_VALIDATION_Bit_Equal ) & (INPUT_VALIDATION_Bit_xor_sign) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fdiv) ;

assign INPUT_VALIDATION_Bit_positive_infinity_Caught_Fdiv = ( INPUT_VALIDATION_input_opcode[3] & ( ( INPUT_VALIDATION_Bit_B_zero & ( ~INPUT_VALIDATION_Bit_double_zero )  & (~INPUT_VALIDATION_input_ieee_B[std]) ) | ( INPUT_VALIDATION_Bit_A_infinity & (~INPUT_VALIDATION_Bit_double_infinity) & (~INPUT_VALIDATION_input_ieee_A[std]) ) ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fdiv);

assign INPUT_VALIDATION_Bit_negative_infinity_Caught_Fdiv = ( INPUT_VALIDATION_input_opcode[3] & ( ( INPUT_VALIDATION_Bit_B_zero & ( ~INPUT_VALIDATION_Bit_double_zero )  & (INPUT_VALIDATION_input_ieee_B[std]) ) | ( INPUT_VALIDATION_Bit_A_infinity & (~INPUT_VALIDATION_Bit_double_infinity) & (INPUT_VALIDATION_input_ieee_A[std]) ) ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fdiv);

assign INPUT_VALIDATION_Bit_positive_zero_Caught_Fdiv = (INPUT_VALIDATION_input_opcode[3] & ( ( INPUT_VALIDATION_Bit_A_zero & (~INPUT_VALIDATION_Bit_double_zero) & (~INPUT_VALIDATION_input_ieee_A[std]) ) | ( INPUT_VALIDATION_Bit_B_infinity & (~INPUT_VALIDATION_Bit_double_infinity) & (~INPUT_VALIDATION_input_ieee_B[std]) )  ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fdiv);

assign INPUT_VALIDATION_Bit_negative_zero_Caught_Fdiv = (INPUT_VALIDATION_input_opcode[3] & ( ( INPUT_VALIDATION_Bit_A_zero & (~INPUT_VALIDATION_Bit_double_zero) & (INPUT_VALIDATION_input_ieee_A[std]) ) | ( INPUT_VALIDATION_Bit_B_infinity & (~INPUT_VALIDATION_Bit_double_infinity) & (INPUT_VALIDATION_input_ieee_B[std]) )  ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fdiv);

//     exception Flag for Fdiv
assign INPUT_VALIDATION_Output_exception_flag_Fdiv = INPUT_VALIDATION_Bit_SNAN_Caught_Fdiv | INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fdiv | INPUT_VALIDATION_Bit_positive_infinity_Caught_Fdiv | INPUT_VALIDATION_Bit_negative_infinity_Caught_Fdiv | INPUT_VALIDATION_Bit_positive_zero_Caught_Fdiv | INPUT_VALIDATION_Bit_negative_zero_Caught_Fdiv | INPUT_VALIDATION_Bit_Positive_One_Caught_Fdiv | INPUT_VALIDATION_Bit_Negative_One_Caught_Fdiv; 

//Fsqrt Cases
assign INPUT_VALIDATION_Bit_SNAN_Caught_Fsqrt = ( INPUT_VALIDATION_input_opcode[4] &  ( INPUT_VALIDATION_Bit_A_SNAN | INPUT_VALIDATION_Bit_A_QNAN | INPUT_VALIDATION_input_ieee_A[std] ) ) ;

assign INPUT_VALIDATION_Bit_zero_Caught_Fsqrt = ( INPUT_VALIDATION_input_opcode[4] & ( INPUT_VALIDATION_Bit_A_zero & (~INPUT_VALIDATION_input_ieee_A[std]) )  ) ;

assign INPUT_VALIDATION_Bit_Positive_One_Caught_Fsqrt = (INPUT_VALIDATION_input_opcode[4] & ( ( INPUT_VALIDATION_Bit_A_1) & (~INPUT_VALIDATION_input_ieee_A[std]) ) );

assign INPUT_VALIDATION_Bit_positive_infinity_Caught_Fsqrt = ( INPUT_VALIDATION_input_opcode[4] & ( (INPUT_VALIDATION_Bit_A_infinity) & (~INPUT_VALIDATION_input_ieee_A[std]) ) );

//    exception flag for square root
assign INPUT_VALIDATION_Output_exception_flag_Fsqrt = INPUT_VALIDATION_Bit_SNAN_Caught_Fsqrt | INPUT_VALIDATION_Bit_zero_Caught_Fsqrt | INPUT_VALIDATION_Bit_Positive_One_Caught_Fsqrt | INPUT_VALIDATION_Bit_positive_infinity_Caught_Fsqrt ;

//Fmin cases
assign  INPUT_VALIDATION_Bit_SNAN_Caught_Fmin = ( INPUT_VALIDATION_input_opcode[5] & ( INPUT_VALIDATION_Bit_NAN ) ) ;

assign  INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmin = ( INPUT_VALIDATION_input_opcode[5] & ( INPUT_VALIDATION_Bit_B_QNAN) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmin);

assign  INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmin = ( INPUT_VALIDATION_input_opcode[5] & ( INPUT_VALIDATION_Bit_A_QNAN) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmin);

//Fmax cases
assign  INPUT_VALIDATION_Bit_SNAN_Caught_Fmax = ( INPUT_VALIDATION_input_opcode[6] & ( INPUT_VALIDATION_Bit_NAN ) ) ;

assign  INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmax = ( INPUT_VALIDATION_input_opcode[6] & ( INPUT_VALIDATION_Bit_B_QNAN) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmax);

assign  INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmax = ( INPUT_VALIDATION_input_opcode[6] & ( INPUT_VALIDATION_Bit_A_QNAN) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmax);

//Feq Cases
 assign INPUT_VALIDATION_Bit_zero_Caught_Feq =  (  INPUT_VALIDATION_input_opcode[9] &  ( INPUT_VALIDATION_Bit_NAN ) ) ;

//Flt Cases
 assign INPUT_VALIDATION_Bit_zero_Caught_Flt =  (  INPUT_VALIDATION_input_opcode[10] &  ( INPUT_VALIDATION_Bit_NAN ) ) ;

//Fle Cases
 assign INPUT_VALIDATION_Bit_zero_Caught_Fle =  (  INPUT_VALIDATION_input_opcode[11] &  ( INPUT_VALIDATION_Bit_NAN )   ) ;

//   exception flag for comparision block
assign INPUT_VALIDATION_Output_exception_flag_Fcomp = INPUT_VALIDATION_Bit_SNAN_Caught_Fmin | INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmin | INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmin | INPUT_VALIDATION_Bit_SNAN_Caught_Fmax | INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmax | INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmax | INPUT_VALIDATION_Bit_zero_Caught_Feq | INPUT_VALIDATION_Bit_zero_Caught_Flt | INPUT_VALIDATION_Bit_zero_Caught_Fle;

//FMADD Casses
assign INPUT_VALIDATION_Bit_SNAN_Caught_Fmadd =  (  (INPUT_VALIDATION_input_opcode[12] | INPUT_VALIDATION_input_opcode[17] ) &  (  (INPUT_VALIDATION_Bit_single_infinity & INPUT_VALIDATION_Bit_single_zero) |   ( INPUT_VALIDATION_Bit_NAN | INPUT_VALIDATION_Bit_C_SNAN | INPUT_VALIDATION_Bit_C_QNAN ) | ( ( INPUT_VALIDATION_Bit_single_infinity & INPUT_VALIDATION_Bit_C_infinity ) & ( ( (INPUT_VALIDATION_Bit_xor_sign) & (!(INPUT_VALIDATION_input_ieee_C[std])) ) | ( (~INPUT_VALIDATION_Bit_xor_sign) & INPUT_VALIDATION_input_ieee_C[std] )  ) ) ) ) ;                        
assign INPUT_VALIDATION_Bit_Positive_Zero_Caught_Fmadd = ( (INPUT_VALIDATION_input_opcode[12] | INPUT_VALIDATION_input_opcode[17] ) & (  (INPUT_VALIDATION_Bit_single_zero & INPUT_VALIDATION_Bit_C_zero) & ( (~INPUT_VALIDATION_input_ieee_C[std]) | ( (~INPUT_VALIDATION_Bit_xor_sign) & INPUT_VALIDATION_input_ieee_C[std] ) )  )) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmadd);
assign INPUT_VALIDATION_Bit_negative_Zero_Caught_Fmadd =( (INPUT_VALIDATION_input_opcode[12] | INPUT_VALIDATION_input_opcode[17] ) & ( INPUT_VALIDATION_Bit_single_zero & (INPUT_VALIDATION_Bit_xor_sign) & INPUT_VALIDATION_Bit_C_zero & (INPUT_VALIDATION_input_ieee_C[std]) )) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmadd);
assign INPUT_VALIDATION_Bit_positive_infinity_Caught_Fmadd = ( (INPUT_VALIDATION_input_opcode[12] | INPUT_VALIDATION_input_opcode[17] ) & ( (INPUT_VALIDATION_Bit_single_infinity & (~INPUT_VALIDATION_Bit_xor_sign)) | (INPUT_VALIDATION_Bit_C_infinity & (~INPUT_VALIDATION_input_ieee_C[std]) ) )  ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmadd);
assign INPUT_VALIDATION_Bit_negative_infinity_Caught_Fmadd = ( (INPUT_VALIDATION_input_opcode[12] | INPUT_VALIDATION_input_opcode[17] ) & ((INPUT_VALIDATION_Bit_single_infinity & (INPUT_VALIDATION_Bit_xor_sign)) | (INPUT_VALIDATION_Bit_C_infinity & (INPUT_VALIDATION_input_ieee_C[std]) ) )  ) &  (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmadd);
assign INPUT_VALIDATION_Bit_Positive_No_Comp_A_Caught_Fmadd = ( (INPUT_VALIDATION_input_opcode[12] | INPUT_VALIDATION_input_opcode[17] ) & ( INPUT_VALIDATION_Bit_B_1 & (~INPUT_VALIDATION_Bit_xor_sign) & INPUT_VALIDATION_Bit_C_zero & (~INPUT_VALIDATION_Bit_A_infinity) & (~INPUT_VALIDATION_Bit_A_zero) ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmadd);
assign INPUT_VALIDATION_Bit_Negative_No_Comp_A_Caught_Fmadd = ((INPUT_VALIDATION_input_opcode[12] | INPUT_VALIDATION_input_opcode[17] ) & ( INPUT_VALIDATION_Bit_B_1 & (INPUT_VALIDATION_Bit_xor_sign) & INPUT_VALIDATION_Bit_C_zero & (~INPUT_VALIDATION_Bit_A_infinity) & (~INPUT_VALIDATION_Bit_A_zero) )) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmadd) ;
assign INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught_Fmadd = ((INPUT_VALIDATION_input_opcode[12] | INPUT_VALIDATION_input_opcode[17] ) & ( INPUT_VALIDATION_Bit_A_1 & (~INPUT_VALIDATION_Bit_xor_sign) & INPUT_VALIDATION_Bit_C_zero & (~INPUT_VALIDATION_Bit_B_infinity) & (~INPUT_VALIDATION_Bit_B_zero)  )) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmadd);
assign INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught_Fmadd = ((INPUT_VALIDATION_input_opcode[12] | INPUT_VALIDATION_input_opcode[17] ) & ( INPUT_VALIDATION_Bit_A_1 & (INPUT_VALIDATION_Bit_xor_sign) & INPUT_VALIDATION_Bit_C_zero & (~INPUT_VALIDATION_Bit_B_infinity) & (~INPUT_VALIDATION_Bit_B_zero)  )) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmadd);
assign INPUT_VALIDATION_Bit_No_Comp_C_Caught_Fmadd = ( (INPUT_VALIDATION_input_opcode[12] | INPUT_VALIDATION_input_opcode[17] ) & ( INPUT_VALIDATION_Bit_double_zero & (~INPUT_VALIDATION_Bit_C_zero) ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmadd);

//    exception flag for fmadd
assign INPUT_VALIDATION_Output_exception_flag_Fmadd = INPUT_VALIDATION_Bit_SNAN_Caught_Fmadd | INPUT_VALIDATION_Bit_Positive_Zero_Caught_Fmadd | INPUT_VALIDATION_Bit_negative_Zero_Caught_Fmadd | INPUT_VALIDATION_Bit_positive_infinity_Caught_Fmadd | INPUT_VALIDATION_Bit_negative_infinity_Caught_Fmadd | INPUT_VALIDATION_Bit_Positive_No_Comp_A_Caught_Fmadd | INPUT_VALIDATION_Bit_Negative_No_Comp_A_Caught_Fmadd | INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught_Fmadd | INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught_Fmadd | INPUT_VALIDATION_Bit_No_Comp_C_Caught_Fmadd;

//Fmsub Casses
assign INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb =  ( (INPUT_VALIDATION_input_opcode[13] | INPUT_VALIDATION_input_opcode[16]) & ( (INPUT_VALIDATION_Bit_single_infinity & INPUT_VALIDATION_Bit_single_zero) | ( INPUT_VALIDATION_Bit_NAN | INPUT_VALIDATION_Bit_C_SNAN | INPUT_VALIDATION_Bit_C_QNAN) |  ( ( INPUT_VALIDATION_Bit_single_infinity & INPUT_VALIDATION_Bit_C_infinity ) & ( ( (~INPUT_VALIDATION_Bit_xor_sign) & (~INPUT_VALIDATION_input_ieee_C[std])  ) | ( INPUT_VALIDATION_Bit_xor_sign & INPUT_VALIDATION_input_ieee_C[std] )   )  )  ) );
assign INPUT_VALIDATION_Bit_positive_infinity_Caught_Fmsubb = ( (INPUT_VALIDATION_input_opcode[13] | INPUT_VALIDATION_input_opcode[16]) & ((INPUT_VALIDATION_Bit_single_infinity & (~INPUT_VALIDATION_Bit_xor_sign)) | | (INPUT_VALIDATION_Bit_C_infinity & (INPUT_VALIDATION_input_ieee_C[std]) ))) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb);
assign INPUT_VALIDATION_Bit_negative_infinity_Caught_Fmsubb = ( (INPUT_VALIDATION_input_opcode[13] | INPUT_VALIDATION_input_opcode[16]) & ( (INPUT_VALIDATION_Bit_single_infinity & (INPUT_VALIDATION_Bit_xor_sign)) | (INPUT_VALIDATION_Bit_C_infinity & (~INPUT_VALIDATION_input_ieee_C[std]) ) )) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb);
assign INPUT_VALIDATION_Bit_Positive_Zero_Caught_Fmsubb = ( (INPUT_VALIDATION_input_opcode[13] | INPUT_VALIDATION_input_opcode[16]) & (  ( (INPUT_VALIDATION_Bit_single_zero &  INPUT_VALIDATION_Bit_C_zero) & ( (~INPUT_VALIDATION_Bit_xor_sign) | ( INPUT_VALIDATION_Bit_xor_sign & INPUT_VALIDATION_input_ieee_C[std]) ))  ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb) ;
assign INPUT_VALIDATION_Bit_Negative_Zero_Caught_Fmsubb =  ( (INPUT_VALIDATION_input_opcode[13] | INPUT_VALIDATION_input_opcode[16]) & ( INPUT_VALIDATION_Bit_single_zero & INPUT_VALIDATION_Bit_xor_sign & INPUT_VALIDATION_Bit_C_zero & (~INPUT_VALIDATION_input_ieee_C[std])  ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb) ;
assign INPUT_VALIDATION_Bit_Positive_No_Comp_A_Caught_Fmsubb = ( (INPUT_VALIDATION_input_opcode[13] | INPUT_VALIDATION_input_opcode[16]) & ( INPUT_VALIDATION_Bit_B_1 & (~INPUT_VALIDATION_Bit_xor_sign) & INPUT_VALIDATION_Bit_C_zero & (~INPUT_VALIDATION_Bit_A_infinity) & (~INPUT_VALIDATION_Bit_A_zero) ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb);
assign INPUT_VALIDATION_Bit_Negative_No_Comp_A_Caught_Fmsubb = ((INPUT_VALIDATION_input_opcode[13] | INPUT_VALIDATION_input_opcode[16]) & ( INPUT_VALIDATION_Bit_B_1 & (INPUT_VALIDATION_Bit_xor_sign) & INPUT_VALIDATION_Bit_C_zero & (~INPUT_VALIDATION_Bit_A_infinity) & (~INPUT_VALIDATION_Bit_A_zero) )) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb) ;
assign INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught_Fmsubb = ((INPUT_VALIDATION_input_opcode[13] | INPUT_VALIDATION_input_opcode[16]) & ( INPUT_VALIDATION_Bit_A_1 & (~INPUT_VALIDATION_Bit_xor_sign) & INPUT_VALIDATION_Bit_C_zero & (~INPUT_VALIDATION_Bit_B_infinity) & (~INPUT_VALIDATION_Bit_B_zero)  )) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb);
assign INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught_Fmsubb = ((INPUT_VALIDATION_input_opcode[13] | INPUT_VALIDATION_input_opcode[16]) & ( INPUT_VALIDATION_Bit_A_1 & (INPUT_VALIDATION_Bit_xor_sign) & INPUT_VALIDATION_Bit_C_zero & (~INPUT_VALIDATION_Bit_B_infinity) & (~INPUT_VALIDATION_Bit_B_zero)  )) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb);
assign INPUT_VALIDATION_Bit_Positive_No_Comp_C_Caught_Fmsubb = ((INPUT_VALIDATION_input_opcode[13] | INPUT_VALIDATION_input_opcode[16]) & (INPUT_VALIDATION_Bit_double_zero & INPUT_VALIDATION_input_ieee_C[std] & (~INPUT_VALIDATION_Bit_C_zero) ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb) ;
assign INPUT_VALIDATION_Bit_Negative_No_Comp_C_Caught_Fmsubb =  ((INPUT_VALIDATION_input_opcode[13] | INPUT_VALIDATION_input_opcode[16]) & (INPUT_VALIDATION_Bit_double_zero & (~INPUT_VALIDATION_input_ieee_C[std]) & (~INPUT_VALIDATION_Bit_C_zero) ) ) & (~INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb) ;

//    exception flag for fmsubb
assign INPUT_VALIDATION_Output_exception_flag_Fmsub = INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb |INPUT_VALIDATION_Bit_positive_infinity_Caught_Fmsubb |INPUT_VALIDATION_Bit_negative_infinity_Caught_Fmsubb |INPUT_VALIDATION_Bit_Positive_Zero_Caught_Fmsubb |INPUT_VALIDATION_Bit_Negative_Zero_Caught_Fmsubb |INPUT_VALIDATION_Bit_Positive_No_Comp_A_Caught_Fmsubb |INPUT_VALIDATION_Bit_Negative_No_Comp_A_Caught_Fmsubb | INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught_Fmsubb | INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught_Fmsubb | INPUT_VALIDATION_Bit_Positive_No_Comp_C_Caught_Fmsubb | INPUT_VALIDATION_Bit_Negative_No_Comp_C_Caught_Fmsubb;
//################################################ OUTPUT slections ##########################################
//output selection bits
assign INPUT_VALIDATION_Bit_SNAN_Caught = INPUT_VALIDATION_Bit_SNAN_Caught_Fadd | INPUT_VALIDATION_Bit_SNAN_Caught_Fsubb | INPUT_VALIDATION_Bit_SNAN_Caught_Fmul | INPUT_VALIDATION_Bit_SNAN_Caught_Fdiv | INPUT_VALIDATION_Bit_SNAN_Caught_Fsqrt | INPUT_VALIDATION_Bit_SNAN_Caught_Fmin |  INPUT_VALIDATION_Bit_SNAN_Caught_Fmax | INPUT_VALIDATION_Bit_SNAN_Caught_Fmadd | INPUT_VALIDATION_Bit_SNAN_Caught_Fmsubb;

assign INPUT_VALIDATION_Bit_No_Comp_A_Caught = INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fadd | INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fsubb | INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmul | INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fdiv | INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmin | INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmax ;

assign INPUT_VALIDATION_Bit_Positive_No_Comp_A_Caught = INPUT_VALIDATION_Bit_Positive_No_Comp_A_Caught_Fmadd | INPUT_VALIDATION_Bit_Positive_No_Comp_A_Caught_Fmsubb  ;

assign INPUT_VALIDATION_Bit_Negative_No_Comp_A_Caught = INPUT_VALIDATION_Bit_Negative_No_Comp_A_Caught_Fmadd | INPUT_VALIDATION_Bit_Negative_No_Comp_A_Caught_Fmsubb ;

assign INPUT_VALIDATION_Bit_No_Comp_B_Caught = INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fadd | INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmul | INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmin | INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmax ;

assign INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught = INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught_Fmadd | INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught_Fmsubb | INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught_Fsubb ;

assign INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught = INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught_Fmadd | INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught_Fmsubb | INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught_Fsubb ;

assign INPUT_VALIDATION_Bit_No_Comp_C_Caught = INPUT_VALIDATION_Bit_No_Comp_C_Caught_Fmadd ;

assign INPUT_VALIDATION_Bit_Negative_No_Comp_C_Caught = INPUT_VALIDATION_Bit_Negative_No_Comp_C_Caught_Fmsubb;

assign INPUT_VALIDATION_Bit_Positive_No_Comp_C_Caught = INPUT_VALIDATION_Bit_Positive_No_Comp_C_Caught_Fmsubb;

assign INPUT_VALIDATION_Bit_Positive_infinity_Caught = INPUT_VALIDATION_Bit_positive_infinity_Caught_Fadd | INPUT_VALIDATION_Bit_positive_infinity_Caught_Fmul | INPUT_VALIDATION_Bit_positive_infinity_Caught_Fdiv | INPUT_VALIDATION_Bit_positive_infinity_Caught_Fsqrt | INPUT_VALIDATION_Bit_positive_infinity_Caught_Fmadd | INPUT_VALIDATION_Bit_positive_infinity_Caught_Fmsubb;

assign INPUT_VALIDATION_Bit_negative_infinity_Caught = INPUT_VALIDATION_Bit_negitive_infinity_Caught_Fsubb | INPUT_VALIDATION_Bit_negitive_infinity_Caught_Fadd | INPUT_VALIDATION_Bit_negative_infinity_Caught_Fmul | INPUT_VALIDATION_Bit_negative_infinity_Caught_Fdiv | INPUT_VALIDATION_Bit_negative_infinity_Caught_Fmadd | INPUT_VALIDATION_Bit_negative_infinity_Caught_Fmsubb;

assign INPUT_VALIDATION_Bit_positive_zero_Caught = INPUT_VALIDATION_Bit_positive_zero_Caught_Fadd | INPUT_VALIDATION_Bit_positive_zero_Caught_Fsubb | INPUT_VALIDATION_Bit_positive_zero_Caught_Fmul | INPUT_VALIDATION_Bit_positive_zero_Caught_Fdiv | INPUT_VALIDATION_Bit_zero_Caught_Fsqrt | INPUT_VALIDATION_Bit_zero_Caught_Feq | INPUT_VALIDATION_Bit_zero_Caught_Flt | INPUT_VALIDATION_Bit_zero_Caught_Fle | INPUT_VALIDATION_Bit_Positive_Zero_Caught_Fmadd | INPUT_VALIDATION_Bit_Positive_Zero_Caught_Fmsubb ;

assign INPUT_VALIDATION_Bit_negative_zero_Caught = INPUT_VALIDATION_Bit_negitive_zero_Caught_Fadd | INPUT_VALIDATION_Bit_negitive_zero_Caught_Fsubb | INPUT_VALIDATION_Bit_negative_zero_Caught_Fmul | INPUT_VALIDATION_Bit_negative_zero_Caught_Fdiv | INPUT_VALIDATION_Bit_negative_Zero_Caught_Fmadd | INPUT_VALIDATION_Bit_Negative_Zero_Caught_Fmsubb ; 

assign INPUT_VALIDATION_Bit_Positive_One_Caught = INPUT_VALIDATION_Bit_Positive_One_Caught_Fdiv | INPUT_VALIDATION_Bit_Positive_One_Caught_Fsqrt;

assign INPUT_VALIDATION_Bit_Negative_One_Caught = INPUT_VALIDATION_Bit_Negative_One_Caught_Fdiv;


//Exceptional Flag logic

assign INPUT_VALIDATION_Output_invalid_flag = (rst_l) ?  (INPUT_VALIDATION_Bit_SNAN_Caught | INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmin | INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmin | INPUT_VALIDATION_Bit_No_Comp_A_Caught_Fmax | INPUT_VALIDATION_Bit_No_Comp_B_Caught_Fmax | ( (INPUT_VALIDATION_Bit_zero_Caught_Feq) & (INPUT_VALIDATION_Bit_A_SNAN | INPUT_VALIDATION_Bit_B_SNAN) ) | ( (INPUT_VALIDATION_input_opcode[10] |  INPUT_VALIDATION_input_opcode[11]) & (INPUT_VALIDATION_Bit_A_SNAN | INPUT_VALIDATION_Bit_B_SNAN | INPUT_VALIDATION_Bit_A_QNAN | INPUT_VALIDATION_Bit_B_QNAN) ) ) : 1'b0 ;

assign INPUT_VALIDATION_Output_Flag_DZ = (rst_l) ? INPUT_VALIDATION_Bit_positive_infinity_Caught_Fdiv : 1'b0;

// Mux for sleection of coresponding exceptional output and FLags (P.S: Refer to coments against each bolen check)
assign INPUT_VALIDATION_Output_temp_storage = (rst_l) ? (INPUT_VALIDATION_Bit_SNAN_Caught ? 32'h7fa00000 : INPUT_VALIDATION_Bit_No_Comp_A_Caught ? INPUT_VALIDATION_input_ieee_A : INPUT_VALIDATION_Bit_Positive_No_Comp_A_Caught ? {1'b0,INPUT_VALIDATION_input_ieee_A[std-1:0]} : INPUT_VALIDATION_Bit_Negative_No_Comp_A_Caught ? {1'b1,INPUT_VALIDATION_input_ieee_A[std-1:0]} : INPUT_VALIDATION_Bit_No_Comp_B_Caught ? INPUT_VALIDATION_input_ieee_B: INPUT_VALIDATION_Bit_Positive_No_Comp_B_Caught ? {1'b0,INPUT_VALIDATION_input_ieee_B[std-1:0]} : INPUT_VALIDATION_Bit_Negative_No_Comp_B_Caught ? {1'b1,INPUT_VALIDATION_input_ieee_B[std-1:0]}: INPUT_VALIDATION_Bit_No_Comp_C_Caught ? INPUT_VALIDATION_input_ieee_C : INPUT_VALIDATION_Bit_Positive_No_Comp_C_Caught ? {1'b0,INPUT_VALIDATION_input_ieee_C[std-1:0]} : INPUT_VALIDATION_Bit_Negative_No_Comp_C_Caught ? {1'b1,INPUT_VALIDATION_input_ieee_C[std-1:0]} : INPUT_VALIDATION_Bit_negative_infinity_Caught ? 32'hff800000 : INPUT_VALIDATION_Bit_Positive_infinity_Caught ? 32'h7f800000 : INPUT_VALIDATION_Bit_positive_zero_Caught ? 32'h00000000 : INPUT_VALIDATION_Bit_negative_zero_Caught ? 32'h80000000 : INPUT_VALIDATION_Bit_Positive_One_Caught ? 32'h3f800000 : INPUT_VALIDATION_Bit_Negative_One_Caught ? 32'hbf800000 : 32'h00000000) : 32'h00000000 ;

//interupt pin assignment, this will be High if at least one input is either SNAN or QNAN
assign interupt_Pin = (rst_l) ? INPUT_VALIDATION_Bit_SNAN_Caught : 1'b0 ;

endmodule
