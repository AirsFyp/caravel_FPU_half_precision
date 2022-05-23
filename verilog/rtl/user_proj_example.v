// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */
`define MPRJ_IO_PADS 38

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;
    wire rx_i;
    wire [15:0] FPU_hp_result;
    wire [15:0] CLKS_PER_BIT;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;


    // IO for input mode set 1 and for output mode set 0
    assign io_oeb[5] = 1'b1;
    assign io_oeb[23:8] = 16'h0000;
    assign io_out[23:8] = FPU_hp_result;
    
    // Uart Pin
    assign rx_i = (~la_oenb[1]) ? la_data_in[1] : io_in[5];

    // IRQ
    assign irq = 3'b000;	// Unused

    // Ouptut at LA bits [31:16]
    assign la_data_out[31:0] = 32'h00000000;
    assign la_data_out[47:32] = (&la_oenb[47:32]) ? FPU_hp_result : 16'h0000;
    assign la_data_out[127:48] = {79{1'b0}};
    
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    assign clk = (~la_oenb[64]) ? la_data_in[64] : wb_clk_i;
    assign rst = (~la_oenb[65]) ? la_data_in[65] : ~wb_rst_i;
    assign CLKS_PER_BIT = (la_oenb[31:16] == 16'h0000) ? la_data_in[31:16] : 16'd348;
   
   
    // Initiation of TOP Module
    FPU_FSM_TOP FPU_Half_Precision_Top (
    					`ifdef USE_POWER_PINS
    					   .vccd1(vccd1),	// User area 1 1.8V supply
    					   .vssd1(vssd1),	// User area 1 digital ground
					`endif
    					  .clk(clk),
    					  .rst_l(rst),
    					  .r_Rx_Serial(rx_i),
    					  .CLKS_PER_BIT(CLKS_PER_BIT),
    					  .FPU_hp_result(FPU_hp_result)
    					  );

endmodule

`default_nettype wire
