module FPU_exu #(parameter FPLEN = 16) (
input clk,
input rst_l,
input scan_mode,
input valid_execution,
input [3:0] float_control,
input [23:0]          sfpu_op,
input [2:0]           fpu_rnd,
input [2:0]           fpu_pre,
input         dec_i0_rs1_en_d,                               // Qualify GPR RS1 data
input         dec_i0_rs2_en_d,                               // Qualify GPR RS2 data
input [31:0]  gpr_i0_rs1_d,                                  // DEC data gpr
input [31:0]  gpr_i0_rs2_d,                                  // DEC data gpr
input [FPLEN-1:0] fs1_data,
input [FPLEN-1:0] fs2_data,
input [FPLEN-1:0] fs3_data,
input [2:0]fpu_sel,

output [FPLEN-1:0]  fpu_result_1,                           // single cycle result
output [31:0]       fpu_result_rd,                          // integer result
output fpu_complete,
output [4:0] sflags,
output IV_exception,
output fpu_complete_rd

);

wire [23:0] sfpu_op_r;
reg sfpu_alu_valid_r;
wire [FPLEN-1:0]           fs1_d; 
wire [FPLEN-1:0]           fs2_d;
wire [FPLEN-1:0]           fs3_d;
//wire [FPLEN-1:0]           fpu_result_exu;
wire [FPLEN-1:0]           fpu_result_top;
wire [FPLEN-1:0]           fpu_result_rx;
wire [4:0] fpu_flags;
wire [31:0]FPU_Result_rd,Operand_Int;

// sfpu_op [0]  = fadd
// sfpu_op [1]  = fsub
// sfpu_op [2]  = fmul
// sfpu_op [3]  = fdiv
// sfpu_op [4]  = fsqrt
// sfpu_op [5]  = fmin
// sfpu_op [6]  = fmax
// sfpu_op [7]  = fmvx      // int to float     
// sfpu_op [8]  = fmvf      // float to int
// sfpu_op [9]  = feq       // result in rd
// sfpu_op [10] = flt       // result in rd
// sfpu_op [11] = fle       // result in rd
// sfpu_op [12] = fmadd
// sfpu_op [13] = fmsub
// sfpu_op [14] = fcvt_w_p  // float to int
// sfpu_op [15] = fcvt_p_w  // int to float
// sfpu_op [16] = fnmsub
// sfpu_op [17] = fnmadd
// sfpu_op [18] = fsgnj
// sfpu_op [19] = fsgnjn
// sfpu_op [20] = fsgnjx
// sfpu_op [21] = fclass    // result store in rd
// sfpu_op [22] = unsign
// sfpu_op [23] = sign

        rvdffe    #(24) sfpu_op_ff  (.*, .clk(clk), .en(valid_execution & fpu_sel[0]),   .din(sfpu_op),   .dout(sfpu_op_r));
	//rvdffe    #(FPLEN) fpu_result_ff  (.*, .clk(clk), .en(fpu_complete),   .din(fpu_result_exu),   .dout(fpu_result_1));
	rvdffs    #(5)  fpu_flags_ff   (.*, .clk(clk), .en(fpu_complete),   .din(fpu_flags),        .dout(sflags));
	
	always @(posedge clk) begin
		if(rst_l == 1'b0) begin
			sfpu_alu_valid_r <= 1'b0;
		end
		else begin
			sfpu_alu_valid_r <= (|sfpu_op[2:0]) | (|sfpu_op[17:5]) | (|sfpu_op[21:18]);
		end
	end
	
	// FPU operands
	assign fs1_d[15:0] =  	(rst_l == 1'b0) ?  {FPLEN{1'b0}} : (({FPLEN{valid_execution &  dec_i0_rs1_en_d &                  ~float_control[0]}} & gpr_i0_rs1_d[31:0]     ) |
								     ({FPLEN{valid_execution & ~dec_i0_rs1_en_d & float_control[0]                  }} & fs1_data               ));
	assign Operand_Int = (rst_l == 1'b0) ? 32'h00000000 : (({32{valid_execution &  dec_i0_rs1_en_d &                  ~float_control[0]}} & gpr_i0_rs1_d[31:0]     )) ;
	assign fs2_d[15:0] =  	(rst_l == 1'b0) ? {FPLEN{1'b0}} : (({FPLEN{valid_execution & float_control[1] }} & fs2_data       ));
	
	assign fs3_d[15:0] =  	(rst_l == 1'b0) ? {FPLEN{1'b0}} : (({FPLEN{valid_execution & float_control[2] }} & fs3_data       ));
								    
					
	// FPU Top Module
	FPU_Top Floating_Top (
				.clk(clk),
				.rst_l(rst_l),
				.frm(fpu_rnd),
				.sfpu_op(sfpu_op),
				.vfpu_op(28'h0000000),
				.fpu_sel(fpu_sel),
				.Operand_A(fs1_d),
				.Operand_B(fs2_d),
				.Operand_C(fs3_d),    
				.FPU_resultant(fpu_result_top), 
				.S_Flags(fpu_flags),
				.Exception_flag(IV_exception),
				.interupt_Pin(),
				.FPU_Result_rd(FPU_Result_rd),
				.Operand_Int(Operand_Int)
			      );



	assign fpu_complete = (rst_l == 1'b0) ? 1'b0 : (sfpu_alu_valid_r) ? 1'b1 : 1'b0;
	
	// FPU FPR Result
	assign fpu_result_1 = (rst_l == 1'b0) ? {FPLEN{1'b0}} : (fpu_complete & (|sfpu_op_r[2:0] | (|sfpu_op_r[17:15]) | sfpu_op_r[7] | (|sfpu_op_r[20:18]) | (|sfpu_op_r[6:5]) | (|sfpu_op_r[13:12]))) ? fpu_result_top : {FPLEN{1'b0}};
								   
	
	// FPU GPR result
	assign fpu_result_rd = (rst_l == 1'b0) ? {32{1'b0}} : (fpu_complete & ((|sfpu_op_r[11:9]) | sfpu_op_r[14] | sfpu_op_r[8] | sfpu_op_r[21])) ? FPU_Result_rd : 
								   {32{1'b0}};
	assign fpu_complete_rd = (~rst_l) ? 1'b0 : (fpu_complete & ((|sfpu_op_r[11:8]) | sfpu_op_r[14] | sfpu_op_r[21])) ? 1'b1 : 1'b0;
endmodule
