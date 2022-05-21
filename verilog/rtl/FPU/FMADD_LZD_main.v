/*`include "fma_LZD_L0.v"
`include "fma_LZD_L1.v"
`include "fma_LZD_L2.v"
`include "fma_LZD_L3.v"
`include "fma_LZD_L4.v"*/

module FMADD_PN_LZD (FMADD_PN_LZD_input_man_48, FMADD_PN_LZD_output_pos);

parameter lzd = 4;
parameter man = 22;

input [23 : 0]FMADD_PN_LZD_input_man_48;

output [lzd : 0]FMADD_PN_LZD_output_pos;

wire [4 : 0]FMADD_PN_LZD_output_pos_interim_1;
wire [5 : 0]FMADD_PN_LZD_output_pos_interim_2;

wire [23 : 0] LZD_wire_output_L0;
wire [17 : 0] LZD_wire_output_L1;
wire [11 : 0] LZD_wire_output_L2;
wire [9 : 0] LZD_wire_output_L3;

//Layer 0
FMADD_LZD_layer_0 L0 (.L0_input_man_48(FMADD_PN_LZD_input_man_48), .L0_output_pos_val(LZD_wire_output_L0));

//Layer 1
FMADD_LZD_layer_1 L1 (.L1_input_pos_val(LZD_wire_output_L0), .L1_output_pos_val(LZD_wire_output_L1));

//Layer 2
FMADD_LZD_layer_2 L2 (.L2_input_pos_val(LZD_wire_output_L1), .L2_output_pos_val(LZD_wire_output_L2));

//Layer 3
FMADD_LZD_layer_3 L3 (.L3_input_pos_val(LZD_wire_output_L2), .L3_output_pos_val(LZD_wire_output_L3));

//Layer 4
FMADD_LZD_layer_4 L4 (.L4_input_pos_val(LZD_wire_output_L3), .L4_output_pos(FMADD_PN_LZD_output_pos_interim_1));

assign FMADD_PN_LZD_output_pos_interim_2 = 
(man == 22) ? (({1'b0,FMADD_PN_LZD_output_pos_interim_1}) + 6'b011000) : //-8 for SP
(man == 9 ) ? (({1'b0,FMADD_PN_LZD_output_pos_interim_1}) + 6'b101011) : //-21 for IEEE16
			  (({1'b0,FMADD_PN_LZD_output_pos_interim_1}) + 6'b101000) ; //-24 for Bf16


assign FMADD_PN_LZD_output_pos = FMADD_PN_LZD_output_pos_interim_2[lzd : 0];

endmodule