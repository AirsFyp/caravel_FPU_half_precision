module Inst_check(
	input clk,
	input rst_l,
	input [6:0] inst_opcode,
	input fpu_complete,
	input halt_req,
	output stall_scalar,
	output fpu_active
);

 localparam FPU_X_RANDOM = 7'h53;
 localparam FPU_X_FADD = 7'h43;
 localparam FPU_X_FSUB = 7'h47; 
 localparam FPU_X_FNADD = 7'h4F;
 localparam FPU_X_FNSUB = 7'h4B;
 reg halt;	      

assign stall_scalar = (rst_l == 1'b0) ? 1'b0 : (halt_req | halt) ? 1'b1 : 1'b0;    		    
	      
assign fpu_active = (rst_l == 1'b0) ? 1'b0 : ((inst_opcode == FPU_X_RANDOM | inst_opcode == FPU_X_FADD | inst_opcode == FPU_X_FSUB | inst_opcode == FPU_X_FNADD | inst_opcode == FPU_X_FNSUB)) ?  1'b1 : (halt) ? fpu_active : 1'b0;  

always @(posedge clk) begin
	if(rst_l == 1'b0) begin
	halt <= 1'b0;
	end
	else if(halt_req) begin
	halt <= 1'b1;
	end
	else if(fpu_complete) begin
	halt <= 1'b0;
	end
	else begin
	halt <= halt;
	end
end

endmodule
