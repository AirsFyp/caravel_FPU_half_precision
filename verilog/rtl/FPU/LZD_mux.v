module FPU_LZD_mux  (in_pos_1, in_val_1, in_pos_2, in_val_2, out_pos, out_val);

//Position of MSB set will be termed as P2
//Position of LSB set will be termed as P1 

parameter layer = 1;

input [layer-1 : 0] in_pos_1, in_pos_2;
input in_val_1, in_val_2;

output [layer : 0]out_pos;
output out_val;

assign out_val = in_val_1 | in_val_2;
assign out_pos = in_val_2 ? {!in_val_2, in_pos_2} : {!in_val_2, in_pos_1} ; 

endmodule
