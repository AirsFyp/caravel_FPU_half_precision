//`include "LZD_comb.v"

module FMADD_LZD_layer_0 (L0_input_man_48, L0_output_pos_val);

input [23:0] L0_input_man_48;
output [23:0] L0_output_pos_val;

wire L0_wire_pos_0 , L0_wire_val_0 ;
wire L0_wire_pos_1 , L0_wire_val_1 ;
wire L0_wire_pos_2 , L0_wire_val_2 ;
wire L0_wire_pos_3 , L0_wire_val_3 ;
wire L0_wire_pos_4 , L0_wire_val_4 ;
wire L0_wire_pos_5 , L0_wire_val_5 ;
wire L0_wire_pos_6 , L0_wire_val_6 ;
wire L0_wire_pos_7 , L0_wire_val_7 ;
wire L0_wire_pos_8 , L0_wire_val_8;
wire L0_wire_pos_9 , L0_wire_val_9 ;
wire L0_wire_pos_10 , L0_wire_val_10 ;
wire L0_wire_pos_11 , L0_wire_val_11 ;


//Layer 0
FPU_LZD_comb L0_0  (.in_bits(L0_input_man_48[1:0]),   .out_pos(L0_wire_pos_0),  .out_val(L0_wire_val_0));
FPU_LZD_comb L0_1  (.in_bits(L0_input_man_48[3:2]),   .out_pos(L0_wire_pos_1),  .out_val(L0_wire_val_1));
FPU_LZD_comb L0_2  (.in_bits(L0_input_man_48[5:4]),   .out_pos(L0_wire_pos_2),  .out_val(L0_wire_val_2));
FPU_LZD_comb L0_3  (.in_bits(L0_input_man_48[7:6]),   .out_pos(L0_wire_pos_3),  .out_val(L0_wire_val_3));
FPU_LZD_comb L0_4  (.in_bits(L0_input_man_48[9:8]),   .out_pos(L0_wire_pos_4),  .out_val(L0_wire_val_4));
FPU_LZD_comb L0_5  (.in_bits(L0_input_man_48[11:10]), .out_pos(L0_wire_pos_5),  .out_val(L0_wire_val_5));
FPU_LZD_comb L0_6  (.in_bits(L0_input_man_48[13:12]), .out_pos(L0_wire_pos_6),  .out_val(L0_wire_val_6));
FPU_LZD_comb L0_7  (.in_bits(L0_input_man_48[15:14]), .out_pos(L0_wire_pos_7),  .out_val(L0_wire_val_7));
FPU_LZD_comb L0_8  (.in_bits(L0_input_man_48[17:16]), .out_pos(L0_wire_pos_8),  .out_val(L0_wire_val_8));
FPU_LZD_comb L0_9  (.in_bits(L0_input_man_48[19:18]), .out_pos(L0_wire_pos_9),  .out_val(L0_wire_val_9));
FPU_LZD_comb L0_10 (.in_bits(L0_input_man_48[21:20]), .out_pos(L0_wire_pos_10), .out_val(L0_wire_val_10));
FPU_LZD_comb L0_11 (.in_bits(L0_input_man_48[23:22]), .out_pos(L0_wire_pos_11), .out_val(L0_wire_val_11));

assign L0_output_pos_val = 
{L0_wire_val_11, L0_wire_pos_11,
 L0_wire_val_10, L0_wire_pos_10,
 L0_wire_val_9, L0_wire_pos_9, 
 L0_wire_val_8, L0_wire_pos_8, 
 L0_wire_val_7, L0_wire_pos_7, 
 L0_wire_val_6, L0_wire_pos_6, 
 L0_wire_val_5, L0_wire_pos_5, 
 L0_wire_val_4, L0_wire_pos_4, 
 L0_wire_val_3, L0_wire_pos_3, 
 L0_wire_val_2, L0_wire_pos_2, 
 L0_wire_val_1, L0_wire_pos_1,
 L0_wire_val_0, L0_wire_pos_0};


endmodule

