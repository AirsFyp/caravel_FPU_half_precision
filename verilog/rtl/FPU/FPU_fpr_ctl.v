// SPDX-License-Identifier: Apache-2.0
// Copyright 2020 MERL Corporation or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module FPU_fpr_ctl
#(
  parameter FPLEN = 16
 )  (
 
    input rden0,
    input rden1,
    input rden2,
    
    input  [4:0]  raddr0,       // logical read addresses
    input  [4:0]  raddr1,
    input  [4:0]  raddr2,

    input         wen0,         // write enable
    input  [4:0]  waddr0,       // write address
    input  [FPLEN-1:0] wd0,          // write data

    input         clk,
    input         rst_l,

    output  [FPLEN-1:0] rd0,         // read data
    output  [FPLEN-1:0] rd1,
    output  [FPLEN-1:0] rd2,

    input          scan_mode
);

   wire [FPLEN-1:0] fpr_out [31:0];      // 32 x 32 bit FPRs
   reg  [FPLEN-1:0] fpr_in  [31:0];
   reg  [31:0] w0v;
   wire [31:0] fpr_wr_en;

   // FPR Write Enables
   assign fpr_wr_en[31:0] = (rst_l == 1'b0) ? {32{1'b1}} : (w0v[31:0]);
   
generate   
   for (genvar j=0; j<32; j++)  begin : fpr
      rvdffe #(16) fprff (.*, .en(fpr_wr_en[j]), .din(fpr_in[j][FPLEN-1:0]), .dout(fpr_out[j][FPLEN-1:0]));
   end : fpr
endgenerate


      // FPR Read logic
      assign rd0 = (rst_l  == 1'b0) ? {FPLEN{1'b0}} : ((rden0 == 1'b1)) ? fpr_out[raddr0][FPLEN-1:0] : {FPLEN{1'b0}};
      assign rd1 = (rst_l  == 1'b0) ? {FPLEN{1'b0}} : ((rden1 == 1'b1)) ? fpr_out[raddr1][FPLEN-1:0] : {FPLEN{1'b0}};
      assign rd2 = (rst_l  == 1'b0) ? {FPLEN{1'b0}} : ((rden2 == 1'b1)) ? fpr_out[raddr2][FPLEN-1:0] : {FPLEN{1'b0}};  
   
      // FPR write logic   
integer j;
   always @(*) begin
       if(rst_l == 1'b0) begin
          w0v = 32'h00000000;
          for(j=0; j<32; j=j+1) begin
             fpr_in[j] = {FPLEN{1'b0}};
          end
       end
      else begin 
          for (int j=0; j<32; j++ )  begin
             w0v[j]     = wen0  & (waddr0[4:0] == j );
             fpr_in[j]  =    ({FPLEN{w0v[j]}} & wd0[FPLEN-1:0]);
    	  end
      end
   end 

endmodule
