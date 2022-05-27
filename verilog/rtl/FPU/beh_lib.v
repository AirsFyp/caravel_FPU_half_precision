module rvdff (
	din,
	clk,
	rst_l,
	dout
);
	parameter WIDTH = 1;
	parameter SHORT = 0;
	input wire [WIDTH - 1:0] din;
	input wire clk;
	input wire rst_l;
	output reg [WIDTH - 1:0] dout;
	generate
		if (SHORT == 1) begin
			wire [WIDTH:1] sv2v_tmp_70387;
			assign sv2v_tmp_70387 = din;
			always @(*) dout = sv2v_tmp_70387;
		end
		else always @(posedge clk or negedge rst_l)
			if (rst_l == 0)
				dout[WIDTH - 1:0] <= {{WIDTH{0}};
			else
				dout[WIDTH - 1:0] <= din[WIDTH - 1:0];
	endgenerate
endmodule
module rvdffs (
	din,
	en,
	clk,
	rst_l,
	dout
);
	parameter WIDTH = 1;
	parameter SHORT = 0;
	input wire [WIDTH - 1:0] din;
	input wire en;
	input wire clk;
	input wire rst_l;
	output wire [WIDTH - 1:0] dout;
	generate
		if (SHORT == 1) begin : genblock
			assign dout = din;
		end
		else begin : genblock
			rvdff #(WIDTH) dffs(
				.din((en ? din[WIDTH - 1:0] : dout[WIDTH - 1:0])),
				.clk(clk),
				.rst_l(rst_l),
				.dout(dout)
			);
		end
	endgenerate
endmodule
module rvdffsc (
	din,
	en,
	clear,
	clk,
	rst_l,
	dout
);
	parameter WIDTH = 1;
	parameter SHORT = 0;
	input wire [WIDTH - 1:0] din;
	input wire en;
	input wire clear;
	input wire clk;
	input wire rst_l;
	output wire [WIDTH - 1:0] dout;
	wire [WIDTH - 1:0] din_new;
	generate
		if (SHORT == 1) begin
			assign dout = din;
		end
		else begin
			assign din_new = {WIDTH {~clear}} & (en ? din[WIDTH - 1:0] : dout[WIDTH - 1:0]);
			rvdff #(WIDTH) dffsc(
				.din(din_new[WIDTH - 1:0]),
				.clk(clk),
				.rst_l(rst_l),
				.dout(dout)
			);
		end
	endgenerate
endmodule
module rvdff_fpga (
	din,
	clk,
	clken,
	rawclk,
	rst_l,
	dout
);
	parameter WIDTH = 1;
	parameter SHORT = 0;
	input wire [WIDTH - 1:0] din;
	input wire clk;
	input wire clken;
	input wire rawclk;
	input wire rst_l;
	output wire [WIDTH - 1:0] dout;
	generate
		if (SHORT == 1) begin
			assign dout = din;
		end
		else rvdffs #(WIDTH) dffs(
			.clk(rawclk),
			.en(clken),
			.din(din),
			.rst_l(rst_l),
			.dout(dout)
		);
	endgenerate
endmodule
module rvdffs_fpga (
	din,
	en,
	clk,
	clken,
	rawclk,
	rst_l,
	dout
);
	parameter WIDTH = 1;
	parameter SHORT = 0;
	input wire [WIDTH - 1:0] din;
	input wire en;
	input wire clk;
	input wire clken;
	input wire rawclk;
	input wire rst_l;
	output wire [WIDTH - 1:0] dout;
	generate
		if (SHORT == 1) begin : genblock
			assign dout = din;
		end
		else begin : genblock
			rvdffs #(WIDTH) dffs(
				.clk(rawclk),
				.en(clken & en),
				.din(din),
				.rst_l(rst_l),
				.dout(dout)
			);
		end
	endgenerate
endmodule
module rvdffsc_fpga (
	din,
	en,
	clear,
	clk,
	clken,
	rawclk,
	rst_l,
	dout
);
	parameter WIDTH = 1;
	parameter SHORT = 0;
	input wire [WIDTH - 1:0] din;
	input wire en;
	input wire clear;
	input wire clk;
	input wire clken;
	input wire rawclk;
	input wire rst_l;
	output wire [WIDTH - 1:0] dout;
	wire [WIDTH - 1:0] din_new;
	generate
		if (SHORT == 1) begin
			assign dout = din;
		end
		else rvdffs #(WIDTH) dffs(
			.clk(rawclk),
			.din(din[WIDTH - 1:0] & {WIDTH {~clear}}),
			.en((en | clear) & clken),
			.rst_l(rst_l),
			.dout(dout)
		);
	endgenerate
endmodule
module rvdffe (
	din,
	en,
	clk,
	rst_l,
	scan_mode,
	dout
);
	parameter WIDTH = 1;
	parameter SHORT = 0;
	parameter OVERRIDE = 0;
	input wire [WIDTH - 1:0] din;
	input wire en;
	input wire clk;
	input wire rst_l;
	input wire scan_mode;
	output wire [WIDTH - 1:0] dout;
	wire l1clk;
	generate
		if (SHORT == 1) begin
				assign dout = din;
		end
		else begin
			if ((WIDTH >= 8) || (OVERRIDE == 1)) begin
				rvdffs #(WIDTH) dff(
					.din(din),
					.en(en),
					.clk(clk),
					.rst_l(rst_l),
					.dout(dout)
				);
			end
		end
	endgenerate
endmodule
module rvdffpcie (
	din,
	clk,
	rst_l,
	en,
	scan_mode,
	dout
);
	parameter WIDTH = 31;
	input wire [WIDTH - 1:0] din;
	input wire clk;
	input wire rst_l;
	input wire en;
	input wire scan_mode;
	output wire [WIDTH - 1:0] dout;
	generate
		if (WIDTH == 31) begin : genblock
			rvdffs #(WIDTH) dff(
				.din(din),
				.en(en),
				.clk(clk),
				.rst_l(rst_l),
				.dout(dout)
			);
		end
	endgenerate
endmodule
module rvdfflie (
	din,
	clk,
	rst_l,
	en,
	scan_mode,
	dout
);
	parameter WIDTH = 16;
	parameter LEFT = 8;
	input wire [WIDTH - 1:0] din;
	input wire clk;
	input wire rst_l;
	input wire en;
	input wire scan_mode;
	output wire [WIDTH - 1:0] dout;
	localparam EXTRA = WIDTH - LEFT;
	localparam LMSB = WIDTH - 1;
	localparam LLSB = (LMSB - LEFT) + 1;
	localparam XMSB = LLSB - 1;
	localparam XLSB = LLSB - EXTRA;
	generate
		if (((WIDTH >= 16) && (LEFT >= 8)) && (EXTRA >= 8)) begin : genblock
			rvdffs #(WIDTH) dff(
				.din(din),
				.en(en),
				.clk(clk),
				.rst_l(rst_l),
				.dout(dout)
			);
		end
	endgenerate
endmodule
module rvdffppe (
	din,
	clk,
	rst_l,
	en,
	scan_mode,
	dout
);
	parameter WIDTH = 32;
	input wire [WIDTH - 1:0] din;
	input wire clk;
	input wire rst_l;
	input wire en;
	input wire scan_mode;
	output wire [WIDTH - 1:0] dout;
	localparam RIGHT = 31;
	localparam LEFT = WIDTH - RIGHT;
	localparam LMSB = WIDTH - 1;
	localparam LLSB = (LMSB - LEFT) + 1;
	localparam RMSB = LLSB - 1;
	localparam RLSB = LLSB - RIGHT;
	generate
		if (((WIDTH >= 32) && (LEFT >= 8)) && 1'd1) begin : genblock
			rvdffs #(WIDTH) dff(
				.din(din),
				.en(en),
				.clk(clk),
				.rst_l(rst_l),
				.dout(dout)
			);
		end
	endgenerate
endmodule
module rvdffie (
	din,
	clk,
	rst_l,
	scan_mode,
	dout
);
	parameter WIDTH = 1;
	parameter OVERRIDE = 0;
	input wire [WIDTH - 1:0] din;
	input wire clk;
	input wire rst_l;
	input wire scan_mode;
	output wire [WIDTH - 1:0] dout;
	wire l1clk;
	wire en;
	generate
		if ((WIDTH >= 8) || (OVERRIDE == 1)) begin : genblock
			assign en = |(din ^ dout);
			rvdffs #(WIDTH) dff(
				.din(din),
				.en(en),
				.clk(clk),
				.rst_l(rst_l),
				.dout(dout)
			);
		end
	endgenerate
endmodule
module rvdffiee (
	din,
	clk,
	rst_l,
	scan_mode,
	en,
	dout
);
	parameter WIDTH = 1;
	parameter OVERRIDE = 0;
	input wire [WIDTH - 1:0] din;
	input wire clk;
	input wire rst_l;
	input wire scan_mode;
	input wire en;
	output wire [WIDTH - 1:0] dout;
	wire l1clk;
	wire final_en;
	generate
		if ((WIDTH >= 8) || (OVERRIDE == 1)) begin : genblock
			assign final_en = |(din ^ dout) & en;
			rvdffs #(WIDTH) dff(
				.din(din),
				.clk(clk),
				.rst_l(rst_l),
				.dout(dout),
				.en(final_en)
			);
		end
	endgenerate
endmodule
module rvsyncss (
	clk,
	rst_l,
	din,
	dout
);
	parameter WIDTH = 251;
	input wire clk;
	input wire rst_l;
	input wire [WIDTH - 1:0] din;
	output wire [WIDTH - 1:0] dout;
	wire [WIDTH - 1:0] din_ff1;
	rvdff #(WIDTH) sync_ff1(
		.clk(clk),
		.rst_l(rst_l),
		.din(din[WIDTH - 1:0]),
		.dout(din_ff1[WIDTH - 1:0])
	);
	rvdff #(WIDTH) sync_ff2(
		.clk(clk),
		.rst_l(rst_l),
		.din(din_ff1[WIDTH - 1:0]),
		.dout(dout[WIDTH - 1:0])
	);
endmodule
module rvsyncss_fpga (
	gw_clk,
	rawclk,
	clken,
	rst_l,
	din,
	dout
);
	parameter WIDTH = 251;
	input wire gw_clk;
	input wire rawclk;
	input wire clken;
	input wire rst_l;
	input wire [WIDTH - 1:0] din;
	output wire [WIDTH - 1:0] dout;
	wire [WIDTH - 1:0] din_ff1;
	rvdff_fpga #(WIDTH) sync_ff1(
		.rst_l(rst_l),
		.clk(gw_clk),
		.rawclk(rawclk),
		.clken(clken),
		.din(din[WIDTH - 1:0]),
		.dout(din_ff1[WIDTH - 1:0])
	);
	rvdff_fpga #(WIDTH) sync_ff2(
		.rst_l(rst_l),
		.clk(gw_clk),
		.rawclk(rawclk),
		.clken(clken),
		.din(din_ff1[WIDTH - 1:0]),
		.dout(dout[WIDTH - 1:0])
	);
endmodule
module rvlsadder (
	rs1,
	offset,
	dout
);
	input wire [31:0] rs1;
	input wire [11:0] offset;
	output wire [31:0] dout;
	wire cout;
	wire sign;
	wire [31:12] rs1_inc;
	wire [31:12] rs1_dec;
	assign {cout, dout[11:0]} = {1'b0, rs1[11:0]} + {1'b0, offset[11:0]};
	assign rs1_inc[31:12] = rs1[31:12] + 1;
	assign rs1_dec[31:12] = rs1[31:12] - 1;
	assign sign = offset[11];
	assign dout[31:12] = (({20 {sign ~^ cout}} & rs1[31:12]) | ({20 {~sign & cout}} & rs1_inc[31:12])) | ({20 {sign & ~cout}} & rs1_dec[31:12]);
endmodule
module rvbradder (
	pc,
	offset,
	dout
);
	input [31:1] pc;
	input [12:1] offset;
	output [31:1] dout;
	wire cout;
	wire sign;
	wire [31:13] pc_inc;
	wire [31:13] pc_dec;
	assign {cout, dout[12:1]} = {1'b0, pc[12:1]} + {1'b0, offset[12:1]};
	assign pc_inc[31:13] = pc[31:13] + 1;
	assign pc_dec[31:13] = pc[31:13] - 1;
	assign sign = offset[12];
	assign dout[31:13] = (({19 {sign ~^ cout}} & pc[31:13]) | ({19 {~sign & cout}} & pc_inc[31:13])) | ({19 {sign & ~cout}} & pc_dec[31:13]);
endmodule
module rvtwoscomp (
	din,
	dout
);
	parameter WIDTH = 32;
	input wire [WIDTH - 1:0] din;
	output wire [WIDTH - 1:0] dout;
	wire [WIDTH - 1:1] dout_temp;
	genvar i;
	generate
		for (i = 1; i < WIDTH; i = i + 1) begin : flip_after_first_one
			assign dout_temp[i] = (|din[i - 1:0] ? ~din[i] : din[i]);
		end
	endgenerate
	assign dout[WIDTH - 1:0] = {dout_temp[WIDTH - 1:1], din[0]};
endmodule
module rvfindfirst1 (
	din,
	dout
);
	parameter WIDTH = 32;
	parameter SHIFT = $clog2(WIDTH);
	input wire [WIDTH - 1:0] din;
	output reg [SHIFT - 1:0] dout;
	reg done;
	always @(*) begin
		dout[SHIFT - 1:0] = {SHIFT {1'b0}};
		done = 1'b0;
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = WIDTH - 1; i > 0; i = i - 1)
				begin : find_first_one
					done = done | din[i];
					dout[SHIFT - 1:0] = dout[SHIFT - 1:0] + (done ? 1'b0 : 1'b1);
				end
		end
	end
endmodule
module rvfindfirst1hot (
	din,
	dout
);
	parameter WIDTH = 32;
	input wire [WIDTH - 1:0] din;
	output reg [WIDTH - 1:0] dout;
	reg done;
	always @(*) begin
		dout[WIDTH - 1:0] = {WIDTH {1'b0}};
		done = 1'b0;
		begin : sv2v_autoblock_3
			reg signed [31:0] i;
			for (i = 0; i < WIDTH; i = i + 1)
				begin : find_first_one
					dout[i] = ~done & din[i];
					done = done | din[i];
				end
		end
	end
endmodule
module rvmaskandmatch (
	mask,
	data,
	masken,
	match
);
	parameter WIDTH = 32;
	input wire [WIDTH - 1:0] mask;
	input wire [WIDTH - 1:0] data;
	input wire masken;
	output wire match;
	wire [WIDTH - 1:0] matchvec;
	wire masken_or_fullmask;
	assign masken_or_fullmask = masken & ~(&mask[WIDTH - 1:0]);
	assign matchvec[0] = masken_or_fullmask | (mask[0] == data[0]);
	genvar i;
	generate
		for (i = 1; i < WIDTH; i = i + 1) begin : match_after_first_zero
			assign matchvec[i] = (&mask[i - 1:0] & masken_or_fullmask ? 1'b1 : mask[i] == data[i]);
		end
	endgenerate
	assign match = &matchvec[WIDTH - 1:0];
endmodule
module rvrangecheck (
	addr,
	in_range,
	in_region
);
	parameter CCM_SADR = 32'h00000000;
	parameter CCM_SIZE = 128;
	input wire [31:0] addr;
	output wire in_range;
	output wire in_region;
	localparam REGION_BITS = 4;
	localparam MASK_BITS = 10 + $clog2(CCM_SIZE);
	wire [31:0] start_addr;
	wire [3:0] region;
	assign start_addr[31:0] = CCM_SADR;
	assign region[3:0] = start_addr[31:28];
	assign in_region = addr[31:28] == region[3:0];
	generate
		if (CCM_SIZE == 48) begin
			assign in_range = (addr[31:MASK_BITS] == start_addr[31:MASK_BITS]) & ~(&addr[MASK_BITS - 1:MASK_BITS - 2]);
		end
		else assign in_range = addr[31:MASK_BITS] == start_addr[31:MASK_BITS];
	endgenerate
endmodule
module rveven_paritygen (
	data_in,
	parity_out
);
	parameter WIDTH = 16;
	input wire [WIDTH - 1:0] data_in;
	output wire parity_out;
	assign parity_out = ^data_in[WIDTH - 1:0];
endmodule
module rveven_paritycheck (
	data_in,
	parity_in,
	parity_err
);
	parameter WIDTH = 16;
	input wire [WIDTH - 1:0] data_in;
	input wire parity_in;
	output wire parity_err;
	assign parity_err = ^data_in[WIDTH - 1:0] ^ parity_in;
endmodule
module rvecc_encode (
	din,
	ecc_out
);
	input [31:0] din;
	output [6:0] ecc_out;
	wire [5:0] ecc_out_temp;
	assign ecc_out_temp[0] = ((((((((((((((((din[0] ^ din[1]) ^ din[3]) ^ din[4]) ^ din[6]) ^ din[8]) ^ din[10]) ^ din[11]) ^ din[13]) ^ din[15]) ^ din[17]) ^ din[19]) ^ din[21]) ^ din[23]) ^ din[25]) ^ din[26]) ^ din[28]) ^ din[30];
	assign ecc_out_temp[1] = ((((((((((((((((din[0] ^ din[2]) ^ din[3]) ^ din[5]) ^ din[6]) ^ din[9]) ^ din[10]) ^ din[12]) ^ din[13]) ^ din[16]) ^ din[17]) ^ din[20]) ^ din[21]) ^ din[24]) ^ din[25]) ^ din[27]) ^ din[28]) ^ din[31];
	assign ecc_out_temp[2] = ((((((((((((((((din[1] ^ din[2]) ^ din[3]) ^ din[7]) ^ din[8]) ^ din[9]) ^ din[10]) ^ din[14]) ^ din[15]) ^ din[16]) ^ din[17]) ^ din[22]) ^ din[23]) ^ din[24]) ^ din[25]) ^ din[29]) ^ din[30]) ^ din[31];
	assign ecc_out_temp[3] = (((((((((((((din[4] ^ din[5]) ^ din[6]) ^ din[7]) ^ din[8]) ^ din[9]) ^ din[10]) ^ din[18]) ^ din[19]) ^ din[20]) ^ din[21]) ^ din[22]) ^ din[23]) ^ din[24]) ^ din[25];
	assign ecc_out_temp[4] = (((((((((((((din[11] ^ din[12]) ^ din[13]) ^ din[14]) ^ din[15]) ^ din[16]) ^ din[17]) ^ din[18]) ^ din[19]) ^ din[20]) ^ din[21]) ^ din[22]) ^ din[23]) ^ din[24]) ^ din[25];
	assign ecc_out_temp[5] = ((((din[26] ^ din[27]) ^ din[28]) ^ din[29]) ^ din[30]) ^ din[31];
	assign ecc_out[6:0] = {^din[31:0] ^ ^ecc_out_temp[5:0], ecc_out_temp[5:0]};
endmodule
module rvecc_decode (
	en,
	din,
	ecc_in,
	sed_ded,
	dout,
	ecc_out,
	single_ecc_error,
	double_ecc_error
);
	input en;
	input [31:0] din;
	input [6:0] ecc_in;
	input sed_ded;
	output [31:0] dout;
	output [6:0] ecc_out;
	output single_ecc_error;
	output double_ecc_error;
	wire [6:0] ecc_check;
	wire [38:0] error_mask;
	wire [38:0] din_plus_parity;
	wire [38:0] dout_plus_parity;
	assign ecc_check[0] = (((((((((((((((((ecc_in[0] ^ din[0]) ^ din[1]) ^ din[3]) ^ din[4]) ^ din[6]) ^ din[8]) ^ din[10]) ^ din[11]) ^ din[13]) ^ din[15]) ^ din[17]) ^ din[19]) ^ din[21]) ^ din[23]) ^ din[25]) ^ din[26]) ^ din[28]) ^ din[30];
	assign ecc_check[1] = (((((((((((((((((ecc_in[1] ^ din[0]) ^ din[2]) ^ din[3]) ^ din[5]) ^ din[6]) ^ din[9]) ^ din[10]) ^ din[12]) ^ din[13]) ^ din[16]) ^ din[17]) ^ din[20]) ^ din[21]) ^ din[24]) ^ din[25]) ^ din[27]) ^ din[28]) ^ din[31];
	assign ecc_check[2] = (((((((((((((((((ecc_in[2] ^ din[1]) ^ din[2]) ^ din[3]) ^ din[7]) ^ din[8]) ^ din[9]) ^ din[10]) ^ din[14]) ^ din[15]) ^ din[16]) ^ din[17]) ^ din[22]) ^ din[23]) ^ din[24]) ^ din[25]) ^ din[29]) ^ din[30]) ^ din[31];
	assign ecc_check[3] = ((((((((((((((ecc_in[3] ^ din[4]) ^ din[5]) ^ din[6]) ^ din[7]) ^ din[8]) ^ din[9]) ^ din[10]) ^ din[18]) ^ din[19]) ^ din[20]) ^ din[21]) ^ din[22]) ^ din[23]) ^ din[24]) ^ din[25];
	assign ecc_check[4] = ((((((((((((((ecc_in[4] ^ din[11]) ^ din[12]) ^ din[13]) ^ din[14]) ^ din[15]) ^ din[16]) ^ din[17]) ^ din[18]) ^ din[19]) ^ din[20]) ^ din[21]) ^ din[22]) ^ din[23]) ^ din[24]) ^ din[25];
	assign ecc_check[5] = (((((ecc_in[5] ^ din[26]) ^ din[27]) ^ din[28]) ^ din[29]) ^ din[30]) ^ din[31];
	assign ecc_check[6] = (^din[31:0] ^ ^ecc_in[6:0]) & ~sed_ded;
	assign single_ecc_error = (en & (ecc_check[6:0] != 0)) & ecc_check[6];
	assign double_ecc_error = (en & (ecc_check[6:0] != 0)) & ~ecc_check[6];
	generate
		genvar i;
		for (i = 1; i < 40; i = i + 1) assign error_mask[i - 1] = ecc_check[5:0] == i;
	endgenerate
	assign din_plus_parity[38:0] = {ecc_in[6], din[31:26], ecc_in[5], din[25:11], ecc_in[4], din[10:4], ecc_in[3], din[3:1], ecc_in[2], din[0], ecc_in[1:0]};
	assign dout_plus_parity[38:0] = (single_ecc_error ? error_mask[38:0] ^ din_plus_parity[38:0] : din_plus_parity[38:0]);
	assign dout[31:0] = {dout_plus_parity[37:32], dout_plus_parity[30:16], dout_plus_parity[14:8], dout_plus_parity[6:4], dout_plus_parity[2]};
	assign ecc_out[6:0] = {dout_plus_parity[38] ^ (ecc_check[6:0] == 7'b1000000), dout_plus_parity[31], dout_plus_parity[15], dout_plus_parity[7], dout_plus_parity[3], dout_plus_parity[1:0]};
endmodule
module rvecc_encode_64 (
	din,
	ecc_out
);
	input [63:0] din;
	output [6:0] ecc_out;
	assign ecc_out[0] = (((((((((((((((((((((((((((((((((din[0] ^ din[1]) ^ din[3]) ^ din[4]) ^ din[6]) ^ din[8]) ^ din[10]) ^ din[11]) ^ din[13]) ^ din[15]) ^ din[17]) ^ din[19]) ^ din[21]) ^ din[23]) ^ din[25]) ^ din[26]) ^ din[28]) ^ din[30]) ^ din[32]) ^ din[34]) ^ din[36]) ^ din[38]) ^ din[40]) ^ din[42]) ^ din[44]) ^ din[46]) ^ din[48]) ^ din[50]) ^ din[52]) ^ din[54]) ^ din[56]) ^ din[57]) ^ din[59]) ^ din[61]) ^ din[63];
	assign ecc_out[1] = (((((((((((((((((((((((((((((((((din[0] ^ din[2]) ^ din[3]) ^ din[5]) ^ din[6]) ^ din[9]) ^ din[10]) ^ din[12]) ^ din[13]) ^ din[16]) ^ din[17]) ^ din[20]) ^ din[21]) ^ din[24]) ^ din[25]) ^ din[27]) ^ din[28]) ^ din[31]) ^ din[32]) ^ din[35]) ^ din[36]) ^ din[39]) ^ din[40]) ^ din[43]) ^ din[44]) ^ din[47]) ^ din[48]) ^ din[51]) ^ din[52]) ^ din[55]) ^ din[56]) ^ din[58]) ^ din[59]) ^ din[62]) ^ din[63];
	assign ecc_out[2] = (((((((((((((((((((((((((((((((((din[1] ^ din[2]) ^ din[3]) ^ din[7]) ^ din[8]) ^ din[9]) ^ din[10]) ^ din[14]) ^ din[15]) ^ din[16]) ^ din[17]) ^ din[22]) ^ din[23]) ^ din[24]) ^ din[25]) ^ din[29]) ^ din[30]) ^ din[31]) ^ din[32]) ^ din[37]) ^ din[38]) ^ din[39]) ^ din[40]) ^ din[45]) ^ din[46]) ^ din[47]) ^ din[48]) ^ din[53]) ^ din[54]) ^ din[55]) ^ din[56]) ^ din[60]) ^ din[61]) ^ din[62]) ^ din[63];
	assign ecc_out[3] = (((((((((((((((((((((((((((((din[4] ^ din[5]) ^ din[6]) ^ din[7]) ^ din[8]) ^ din[9]) ^ din[10]) ^ din[18]) ^ din[19]) ^ din[20]) ^ din[21]) ^ din[22]) ^ din[23]) ^ din[24]) ^ din[25]) ^ din[33]) ^ din[34]) ^ din[35]) ^ din[36]) ^ din[37]) ^ din[38]) ^ din[39]) ^ din[40]) ^ din[49]) ^ din[50]) ^ din[51]) ^ din[52]) ^ din[53]) ^ din[54]) ^ din[55]) ^ din[56];
	assign ecc_out[4] = (((((((((((((((((((((((((((((din[11] ^ din[12]) ^ din[13]) ^ din[14]) ^ din[15]) ^ din[16]) ^ din[17]) ^ din[18]) ^ din[19]) ^ din[20]) ^ din[21]) ^ din[22]) ^ din[23]) ^ din[24]) ^ din[25]) ^ din[41]) ^ din[42]) ^ din[43]) ^ din[44]) ^ din[45]) ^ din[46]) ^ din[47]) ^ din[48]) ^ din[49]) ^ din[50]) ^ din[51]) ^ din[52]) ^ din[53]) ^ din[54]) ^ din[55]) ^ din[56];
	assign ecc_out[5] = (((((((((((((((((((((((((((((din[26] ^ din[27]) ^ din[28]) ^ din[29]) ^ din[30]) ^ din[31]) ^ din[32]) ^ din[33]) ^ din[34]) ^ din[35]) ^ din[36]) ^ din[37]) ^ din[38]) ^ din[39]) ^ din[40]) ^ din[41]) ^ din[42]) ^ din[43]) ^ din[44]) ^ din[45]) ^ din[46]) ^ din[47]) ^ din[48]) ^ din[49]) ^ din[50]) ^ din[51]) ^ din[52]) ^ din[53]) ^ din[54]) ^ din[55]) ^ din[56];
	assign ecc_out[6] = (((((din[57] ^ din[58]) ^ din[59]) ^ din[60]) ^ din[61]) ^ din[62]) ^ din[63];
endmodule
module rvecc_decode_64 (
	en,
	din,
	ecc_in,
	ecc_error
);
	input en;
	input [63:0] din;
	input [6:0] ecc_in;
	output ecc_error;
	wire [6:0] ecc_check;
	assign ecc_check[0] = ((((((((((((((((((((((((((((((((((ecc_in[0] ^ din[0]) ^ din[1]) ^ din[3]) ^ din[4]) ^ din[6]) ^ din[8]) ^ din[10]) ^ din[11]) ^ din[13]) ^ din[15]) ^ din[17]) ^ din[19]) ^ din[21]) ^ din[23]) ^ din[25]) ^ din[26]) ^ din[28]) ^ din[30]) ^ din[32]) ^ din[34]) ^ din[36]) ^ din[38]) ^ din[40]) ^ din[42]) ^ din[44]) ^ din[46]) ^ din[48]) ^ din[50]) ^ din[52]) ^ din[54]) ^ din[56]) ^ din[57]) ^ din[59]) ^ din[61]) ^ din[63];
	assign ecc_check[1] = ((((((((((((((((((((((((((((((((((ecc_in[1] ^ din[0]) ^ din[2]) ^ din[3]) ^ din[5]) ^ din[6]) ^ din[9]) ^ din[10]) ^ din[12]) ^ din[13]) ^ din[16]) ^ din[17]) ^ din[20]) ^ din[21]) ^ din[24]) ^ din[25]) ^ din[27]) ^ din[28]) ^ din[31]) ^ din[32]) ^ din[35]) ^ din[36]) ^ din[39]) ^ din[40]) ^ din[43]) ^ din[44]) ^ din[47]) ^ din[48]) ^ din[51]) ^ din[52]) ^ din[55]) ^ din[56]) ^ din[58]) ^ din[59]) ^ din[62]) ^ din[63];
	assign ecc_check[2] = ((((((((((((((((((((((((((((((((((ecc_in[2] ^ din[1]) ^ din[2]) ^ din[3]) ^ din[7]) ^ din[8]) ^ din[9]) ^ din[10]) ^ din[14]) ^ din[15]) ^ din[16]) ^ din[17]) ^ din[22]) ^ din[23]) ^ din[24]) ^ din[25]) ^ din[29]) ^ din[30]) ^ din[31]) ^ din[32]) ^ din[37]) ^ din[38]) ^ din[39]) ^ din[40]) ^ din[45]) ^ din[46]) ^ din[47]) ^ din[48]) ^ din[53]) ^ din[54]) ^ din[55]) ^ din[56]) ^ din[60]) ^ din[61]) ^ din[62]) ^ din[63];
	assign ecc_check[3] = ((((((((((((((((((((((((((((((ecc_in[3] ^ din[4]) ^ din[5]) ^ din[6]) ^ din[7]) ^ din[8]) ^ din[9]) ^ din[10]) ^ din[18]) ^ din[19]) ^ din[20]) ^ din[21]) ^ din[22]) ^ din[23]) ^ din[24]) ^ din[25]) ^ din[33]) ^ din[34]) ^ din[35]) ^ din[36]) ^ din[37]) ^ din[38]) ^ din[39]) ^ din[40]) ^ din[49]) ^ din[50]) ^ din[51]) ^ din[52]) ^ din[53]) ^ din[54]) ^ din[55]) ^ din[56];
	assign ecc_check[4] = ((((((((((((((((((((((((((((((ecc_in[4] ^ din[11]) ^ din[12]) ^ din[13]) ^ din[14]) ^ din[15]) ^ din[16]) ^ din[17]) ^ din[18]) ^ din[19]) ^ din[20]) ^ din[21]) ^ din[22]) ^ din[23]) ^ din[24]) ^ din[25]) ^ din[41]) ^ din[42]) ^ din[43]) ^ din[44]) ^ din[45]) ^ din[46]) ^ din[47]) ^ din[48]) ^ din[49]) ^ din[50]) ^ din[51]) ^ din[52]) ^ din[53]) ^ din[54]) ^ din[55]) ^ din[56];
	assign ecc_check[5] = ((((((((((((((((((((((((((((((ecc_in[5] ^ din[26]) ^ din[27]) ^ din[28]) ^ din[29]) ^ din[30]) ^ din[31]) ^ din[32]) ^ din[33]) ^ din[34]) ^ din[35]) ^ din[36]) ^ din[37]) ^ din[38]) ^ din[39]) ^ din[40]) ^ din[41]) ^ din[42]) ^ din[43]) ^ din[44]) ^ din[45]) ^ din[46]) ^ din[47]) ^ din[48]) ^ din[49]) ^ din[50]) ^ din[51]) ^ din[52]) ^ din[53]) ^ din[54]) ^ din[55]) ^ din[56];
	assign ecc_check[6] = ((((((ecc_in[6] ^ din[57]) ^ din[58]) ^ din[59]) ^ din[60]) ^ din[61]) ^ din[62]) ^ din[63];
	assign ecc_error = en & (ecc_check[6:0] != 0);
endmodule
module clockhdr (
	SE,
	EN,
	CK,
	Q
);
	input wire SE;
	input wire EN;
	input wire CK;
	output Q;
	reg en_ff;
	wire enable;
	assign enable = EN | SE;
	always @(CK or enable)
		if (!CK)
			en_ff = enable;
	assign Q = CK & en_ff;
endmodule
module rvoclkhdr (
	en,
	clk,
	scan_mode,
	l1clk
);
	input wire en;
	input wire clk;
	input wire scan_mode;
	output wire l1clk;
	wire SE;
	assign SE = 0;
	assign l1clk = clk;
endmodule
