module dec_gpr_ctl
#(
  parameter XLEN = 32
 )  (
 
    input rden0,
    input rden1,
    
    input  [4:0]  raddr0,       // logical read addresses
    input  [4:0]  raddr1,

    input         wen0,         // write enable
    input  [4:0]  waddr0,       // write address
    input  [XLEN-1:0] wd0,          // write data

    input         clk,
    input         rst_l,

    output  [XLEN-1:0] rd0,         // read data
    output  [XLEN-1:0] rd1,

    input          scan_mode
);

   wire [XLEN-1:0] gpr_out [31:1];      // 31 x 32 bit GPRs
   reg  [XLEN-1:0] gpr_in  [31:1];
   reg  [31:1] w0v;
   wire [31:1] gpr_wr_en;


   // GPR Write Enables
   assign gpr_wr_en[31:1] = (rst_l == 1'b0) ? {31{1'b1}} : (w0v[31:1]);
   
genvar j;   
generate   
   for (j=1; j<32; j=j+1)
      rvdffe #(32) gprff (.*, .en(gpr_wr_en[j]), .din(gpr_in[j][XLEN-1:0]), .dout(gpr_out[j][XLEN-1:0]));
endgenerate


      // GPR Read logic
      assign rd0 = (rst_l  == 1'b0) ? {XLEN{1'b0}} : ((rden0 == 1'b1) & (raddr0 != 5'b00000)) ? gpr_out[raddr0][XLEN-1:0] : {XLEN{1'b0}};
      assign rd1 = (rst_l  == 1'b0) ? {XLEN{1'b0}} : ((rden1 == 1'b1) & (raddr1 != 5'b00000)) ? gpr_out[raddr1][XLEN-1:0] : {XLEN{1'b0}};
   
      // GPR write logic   
integer p;
   always @(*) begin
       if(rst_l == 1'b0) begin
          w0v = 31'h00000000;
          for(p=1; p<32; p=p+1) begin
             gpr_in[p] = {XLEN{1'b0}};
          end
       end
      else begin 
          for (p=1; p<32; p=p+1)  begin
             w0v[p]     = wen0  & (waddr0[4:0] == p );
             gpr_in[p]  =    ({XLEN{w0v[p]}} & wd0[XLEN-1:0]);
    	  end
      end
   end 

endmodule

