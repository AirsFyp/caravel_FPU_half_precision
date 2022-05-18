//`include "LZD_mux.v"

module FMADD_LZD_layer_3 (L3_input_pos_val, L3_output_pos_val);

parameter layer = 3;

//Input of layer 3, Output from layer 2
input [11 :0]L3_input_pos_val;

//Output of layer 3, this will be Input to layer 4
output [9 : 0] L3_output_pos_val;

//Wires
wire L3_wire_output_val_0, L3_wire_output_val_1;
wire [layer : 0] L3_wire_output_pos_0, L3_wire_output_pos_1;


FPU_LZD_mux  L3_0  (.in_val_2(L3_input_pos_val[7]),   .in_pos_2(L3_input_pos_val[6:4]),   .in_val_1(L3_input_pos_val[3]),  .in_pos_1(L3_input_pos_val[2:0]),  .out_pos(L3_wire_output_pos_0), .out_val(L3_wire_output_val_0));  defparam L3_0.layer = 3;

assign L3_wire_output_val_1 = L3_input_pos_val[11];
assign L3_wire_output_pos_1 = {1'b1,L3_input_pos_val[10:8]};

assign L3_output_pos_val = 
{L3_wire_output_val_1, L3_wire_output_pos_1,
 L3_wire_output_val_0, L3_wire_output_pos_0};
endmodule
