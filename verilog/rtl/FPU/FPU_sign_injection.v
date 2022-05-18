module FPU_sign (rst_l,op,IEEE_A,IEEE_B,IEEE_out);
  
  parameter Std = 31; // Means IEEE754 Std 32 Bit Single Precision -1 for bits
  parameter Exp = 7; // Means IEEE754 8 Bit For Exponents in Single Precision -1 for bits
  parameter Man = 22; // Means IEEE754 23 Bit For Mantissa in Single Precision -1 for bits
  
  input rst_l;
  input [2:0] op; // bit 0 sgnj, bit 1 sgnjn, bit 2 sgnjx
  input [Std : 0] IEEE_A; 
  input [Std : 0] IEEE_B;
  output [Std : 0] IEEE_out;
  
  wire [2:0] op_r;
  wire Sign_A, Sign_B;
  wire [Exp : 0] Exp_A;
  wire [Man : 0] Mantissa_A;
  
  
  	// New logic
  	assign Sign_A = (rst_l == 1'b0) ? 1'b0 : IEEE_A[Std];
  	assign Sign_B = (rst_l == 1'b0) ? 1'b0 : IEEE_B[Std];
  	assign Exp_A  = (rst_l == 1'b0) ? 8'h00 : IEEE_A[Std - 1 : Std - Exp - 1];
  	assign Mantissa_A = (rst_l == 1'b0) ? 23'h0 : IEEE_A[Man : 0];
  	assign  IEEE_out = (rst_l == 1'b0) ? 32'h0 : (op[0]) ?  {Sign_B,Exp_A,Mantissa_A} : (op[1]) ? {~Sign_B,Exp_A,Mantissa_A} : (op[2]) ? {(Sign_A ^ Sign_B),Exp_A,Mantissa_A} : 32'h0; 
 
endmodule  
