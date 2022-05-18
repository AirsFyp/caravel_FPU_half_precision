module FPU_I2F_LZD (I2F_LZD_input_int, I2F_LZD_output_pos, I2F_LZD_output_val);

parameter layer = 1;

input [31 : 0]I2F_LZD_input_int;

output [4: 0]I2F_LZD_output_pos;
output I2F_LZD_output_val;

wire [31 : 0] LZD_wire_output_L0;
wire [23 : 0] LZD_wire_output_L1;
wire [15 : 0] LZD_wire_output_L2;
wire [9 : 0] LZD_wire_output_L3;

//Layer 0
LZD_layer_0 L0 (.L0_input_int(I2F_LZD_input_int), .L0_output_pos_val(LZD_wire_output_L0));

//Layer 1
LZD_layer_1 L1 (.L1_input_pos_val(LZD_wire_output_L0), .L1_output_pos_val(LZD_wire_output_L1));

//Layer 2
LZD_layer_2 L2 (.L2_input_pos_val(LZD_wire_output_L1), .L2_output_pos_val(LZD_wire_output_L2));

//Layer 3
LZD_layer_3 L3 (.L3_input_pos_val(LZD_wire_output_L2), .L3_output_pos_val(LZD_wire_output_L3));

//Layer 4
LZD_layer_4 L4 (.L4_input_pos_val(LZD_wire_output_L3), .L4_output_pos(I2F_LZD_output_pos), .L4_output_valid(I2F_LZD_output_val));

endmodule
