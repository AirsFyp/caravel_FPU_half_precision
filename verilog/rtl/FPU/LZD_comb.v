module FPU_LZD_comb (in_bits, out_pos, out_val);

input [1:0]in_bits;

output out_pos;
output out_val;

assign out_pos = !in_bits[1];
assign out_val = |in_bits;

endmodule
