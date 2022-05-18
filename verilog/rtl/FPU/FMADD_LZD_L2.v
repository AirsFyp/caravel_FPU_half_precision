//`include "LZD_mux.v"

module FMADD_LZD_layer_2 (L2_input_pos_val, L2_output_pos_val);

parameter layer = 2;

//Input of layer 2, Output from layer 1
input [17 :0]L2_input_pos_val;

//Output of layer 2, this will be Input to layer 3 
output [11 : 0] L2_output_pos_val;

//Wires
wire L2_wire_output_val_0, L2_wire_output_val_1, L2_wire_output_val_2;
wire [layer : 0] L2_wire_output_pos_0, L2_wire_output_pos_1, L2_wire_output_pos_2;


FPU_LZD_mux L2_0 (.in_val_2(L2_input_pos_val[5]),  .in_pos_2(L2_input_pos_val[4:3]),  .in_val_1(L2_input_pos_val[2]),  .in_pos_1(L2_input_pos_val[1:0]),  .out_pos(L2_wire_output_pos_0), .out_val(L2_wire_output_val_0)); defparam L2_0.layer = 2;
FPU_LZD_mux L2_1 (.in_val_2(L2_input_pos_val[11]),  .in_pos_2(L2_input_pos_val[10:9]),  .in_val_1(L2_input_pos_val[8]),  .in_pos_1(L2_input_pos_val[7:6]),  .out_pos(L2_wire_output_pos_1), .out_val(L2_wire_output_val_1)); defparam L2_1.layer = 2;
FPU_LZD_mux L2_2 (.in_val_2(L2_input_pos_val[17]), .in_pos_2(L2_input_pos_val[16:15]), .in_val_1(L2_input_pos_val[14]),  .in_pos_1(L2_input_pos_val[13:12]),  .out_pos(L2_wire_output_pos_2), .out_val(L2_wire_output_val_2)); defparam L2_2.layer = 2;

assign L2_output_pos_val = 
{L2_wire_output_val_2, L2_wire_output_pos_2,
 L2_wire_output_val_1, L2_wire_output_pos_1,
 L2_wire_output_val_0, L2_wire_output_pos_0};
endmodule
