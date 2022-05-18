//`include "LZD_mux.v"

module LZD_layer_4 (L4_input_pos_val, L4_output_pos, L4_output_valid);

parameter layer = 4;

//Input of layer 4, Output from layer 3
input [9 :0]L4_input_pos_val;

//Output of layer 4, this will be position of Leading 1
output [4 : 0] L4_output_pos;
output L4_output_valid;

//Wires
wire L4_wire_output_val;
wire [layer : 0] L4_wire_output_pos;


FPU_LZD_mux L4_0 (.in_val_2(L4_input_pos_val[9]),   .in_pos_2(L4_input_pos_val[8:5]),   .in_val_1(L4_input_pos_val[4]),  .in_pos_1(L4_input_pos_val[3:0]),  .out_pos(L4_wire_output_pos), .out_val(L4_wire_output_val)); defparam L4_0.layer = 4;

assign L4_output_pos = L4_wire_output_pos;
assign L4_output_valid = L4_wire_output_val;
endmodule
