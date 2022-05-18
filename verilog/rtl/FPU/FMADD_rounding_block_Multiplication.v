module FMADD_ROUND_MUL(FMADD_ROUND_MUL_input_overflow, FMADD_ROUND_MUL_input_sticky_PN, FMADD_ROUND_MUL_input_no, FMADD_ROUND_MUL_input_rm, FMADD_ROUND_MUL_output_no, FMADD_ROUND_MUL_output_S_Flags);

parameter std=31;
parameter man =22;
parameter exp = 7;
parameter biad = 127;


input [man+man+exp+5 : 0]FMADD_ROUND_MUL_input_no;
input [2 : 0] FMADD_ROUND_MUL_input_rm;
input FMADD_ROUND_MUL_input_overflow;
input FMADD_ROUND_MUL_input_sticky_PN;

output [std : 0] FMADD_ROUND_MUL_output_no;
output [2 : 0]FMADD_ROUND_MUL_output_S_Flags;
assign FMADD_ROUND_MUL_output_S_Flags = {FMADD_ROUND_MUL_output_overflow,FMADD_ROUND_MUL_output_underflow,FMADD_ROUND_MUL_output_inexact};


wire FMADD_ROUND_MUL_output_inexact, FMADD_ROUND_MUL_output_underflow, FMADD_ROUND_MUL_output_overflow;
wire FMADD_ROUND_MUL_wire_guard, FMADD_ROUND_MUL_wire_round, FMADD_ROUND_MUL_wire_sticky;
wire FMADD_ROUND_MUL_wire_condition_inf, FMADD_ROUND_MUL_wire_condition_rnte, FMADD_ROUND_MUL_wire_condition_rntmm;
wire FMADD_ROUND_MUL_wire_condition_sticky;
wire FMADD_ROUND_MUL_wire_inc;
wire [man+1 : 0] FMADD_ROUND_MUL_wire_rounded_man;
wire [exp : 0] FMADD_ROUND_MUL_wire_rounded_exp;
wire [man : 0] FMADD_ROUND_MUL_wire_final_man;

assign FMADD_ROUND_MUL_wire_guard  =  FMADD_ROUND_MUL_input_no[man+1];
assign FMADD_ROUND_MUL_wire_round  =  FMADD_ROUND_MUL_input_no[man];
assign FMADD_ROUND_MUL_wire_sticky = |FMADD_ROUND_MUL_input_no[man-1 : 0];

assign FMADD_ROUND_MUL_wire_condition_inf   = ((FMADD_ROUND_MUL_wire_round | FMADD_ROUND_MUL_wire_guard | (FMADD_ROUND_MUL_wire_sticky)) & ((FMADD_ROUND_MUL_input_rm == 3'b011 & ~FMADD_ROUND_MUL_input_no[man+2+man+2+exp+1])|(FMADD_ROUND_MUL_input_rm == 3'b010 & FMADD_ROUND_MUL_input_no[man+2+man+2+exp+1])));  
assign FMADD_ROUND_MUL_wire_condition_rnte  = (FMADD_ROUND_MUL_input_rm == 3'b000 & ((FMADD_ROUND_MUL_wire_guard & (FMADD_ROUND_MUL_wire_round | (FMADD_ROUND_MUL_wire_sticky))) | (FMADD_ROUND_MUL_wire_guard & ((~FMADD_ROUND_MUL_wire_round) & ~(FMADD_ROUND_MUL_wire_sticky)) & FMADD_ROUND_MUL_input_no[man+2])));
assign FMADD_ROUND_MUL_wire_condition_rntmm = (FMADD_ROUND_MUL_input_rm == 3'b100 & ((FMADD_ROUND_MUL_wire_guard & (FMADD_ROUND_MUL_wire_round | (FMADD_ROUND_MUL_wire_sticky))) | (FMADD_ROUND_MUL_wire_guard & ((~FMADD_ROUND_MUL_wire_round) & ~(FMADD_ROUND_MUL_wire_sticky)))));
assign FMADD_ROUND_MUL_wire_condition_sticky = FMADD_ROUND_MUL_input_sticky_PN & (((!FMADD_ROUND_MUL_input_no[man+man+exp+5]) & (FMADD_ROUND_MUL_input_rm == 3'b011)) | (FMADD_ROUND_MUL_input_no[man+man+exp+5] & (FMADD_ROUND_MUL_input_rm == 3'b010)));
//FMADD_ROUND_MUL_wire_condition_sticky logic for rounding on the basis os STICKY bit coming from previous module, inc is done incase sticky_pn == 1 and sign == 0 and rm == 3 OR sticky_pn == 1 and sign ==1 and rm == 10

// Add 1 in case rounding says so. Input_overflow is added so that inc becomes ineffective in case overflow is high
assign FMADD_ROUND_MUL_wire_inc = (FMADD_ROUND_MUL_wire_condition_inf | FMADD_ROUND_MUL_wire_condition_rnte | FMADD_ROUND_MUL_wire_condition_rntmm | FMADD_ROUND_MUL_wire_condition_sticky) & (!FMADD_ROUND_MUL_input_overflow);
assign FMADD_ROUND_MUL_wire_rounded_man = FMADD_ROUND_MUL_input_no[man+2+man+1 : man+2] + FMADD_ROUND_MUL_wire_inc;

//If hidden bit before rounding is zero and after rounding is one then add one in exponent other wise don't
assign FMADD_ROUND_MUL_wire_rounded_exp = ((!FMADD_ROUND_MUL_input_no[man+2+man+1]) & (FMADD_ROUND_MUL_wire_rounded_man[man+1])) ?
FMADD_ROUND_MUL_input_no[man+2+man+2+exp : man+2+man+2]  + 1'b1 : FMADD_ROUND_MUL_input_no[man+2+man+2+exp : man+2+man+2];

//overflow occurs in case the exp and man before rounding is complete zero.
assign FMADD_ROUND_MUL_output_underflow = &(!FMADD_ROUND_MUL_input_no[man+man+exp+4]);
//Inexact is high in case any of the GRS are high or if overflow has occured
assign FMADD_ROUND_MUL_output_inexact = FMADD_ROUND_MUL_wire_guard | FMADD_ROUND_MUL_wire_round | FMADD_ROUND_MUL_wire_sticky | FMADD_ROUND_MUL_input_sticky_PN | FMADD_ROUND_MUL_input_overflow;
//overflow is detected in previous module of PN
assign FMADD_ROUND_MUL_output_overflow = FMADD_ROUND_MUL_input_overflow;

assign FMADD_ROUND_MUL_wire_final_man = FMADD_ROUND_MUL_output_overflow ? 
( {(man+1){1'b0}} ) : FMADD_ROUND_MUL_wire_rounded_man[man : 0];

assign FMADD_ROUND_MUL_output_no = {FMADD_ROUND_MUL_input_no[man+man+exp+5], FMADD_ROUND_MUL_wire_rounded_exp, FMADD_ROUND_MUL_wire_final_man[man:0]};


endmodule