module FPU_decode #(parameter FPLEN = 16)
   (
   input 		clk,
   input 		rst_l,
   input [31:0] 	instr,
   input 		fpu_active,
   input 		fpu_complete,
   input [FPLEN-1:0]fpu_result_1,
   output [2:0] 	scalar_control,
   output [4:0] 	rs1_address,
   output [4:0] 	rs2_address,
   output [4:0] 	rd_address,
   output 	illegal_instr,
   output [23:0]          sfpu_op,
   output [2:0]           fpu_rnd,
   output [2:0]           fpu_pre,
   output  [FPLEN-1:0]   fs1_data,
   output  [FPLEN-1:0]   fs2_data,
   output  [FPLEN-1:0]   fs3_data,
   output valid_execution,
   output illegal_config,
   input scan_mode,
   output [3:0] float_control,
   output halt_req,
   output[2:0]fpu_sel
   );

   // Internal Wire and Reg decleration
      wire [114:0] control_signals;
      reg [114:0] control_signals_r;
      wire [4:0] fs1_addr, fs2_addr, fs3_addr;
      wire [FPLEN-1:0] fs1_data_w, fs2_data_w, fs3_data_w;
      wire [4:0] fd_reg;
      wire [1:0] fdest_pkg; // bit 1 = Floating Load, bit 0 = Floating Execution
      
      // Floating Destination Register FLops
      rvdffsc    #(5) fd_reg_ff_x (.clk(clk), .rst_l(rst_l), .en(valid_execution & control_signals[51] & fpu_active), .clear(((~valid_execution | ~fpu_active) & fpu_complete)), .din(control_signals[57] ? instr[11:7] : 5'h00), .dout(fd_reg));  
      
      //rvdffsc    #(5) fd_reg_ff_wb (.clk(clk), .rst_l(rst_l), .en(fpu_complete_w), .clear(~fpu_active & ~fpu_complete_w & fpu_complete), .din(fd_reg_x), .dout(fd_reg));
      
      // Floating Destination write signal
      rvdffsc    #(2) fdest_pkg_ff_x (.clk(clk), .rst_l(rst_l), .en(valid_execution & control_signals[51] & fpu_active), .clear(((~valid_execution | ~fpu_active) & fpu_complete)), .din({control_signals[113],(control_signals[57] & ~control_signals[112])}), .dout(fdest_pkg));  
      
      //rvdffsc    #(2) fdest_pkg_ff_wb (.clk(clk), .rst_l(rst_l), .en(fpu_complete_w), .clear(~fpu_active & ~fpu_complete_w & fpu_complete), .din(fdest_pkg_x), .dout(fdest_pkg));



   // Initiating Floating Decode Controller
      FPU_dec_ctl FPU_decode_controller (
                        .fpu_active(fpu_active),
                           .instr(instr),
                           .out(control_signals)
                        );
                        
                        
   // Initiating Floating Point Register File  	
      FPU_fpr_ctl floating_point_register_file ( 
                        .clk(clk),
                        .rst_l(rst_l),
                        .rden0(control_signals[54]),
                        .rden1(control_signals[55]),
                        .rden2(control_signals[56]), 
                        .raddr0(fs1_addr),
                        .raddr1(fs2_addr),
                        .raddr2(fs3_addr),
                        .wen0(fpu_complete & fdest_pkg[0]), // single cycle port
                        .waddr0(fd_reg),
                        .wd0(fpu_result_1),          
                        .rd0(fs1_data_w),         // read data
                        .rd1(fs2_data_w),
                        .rd2(fs3_data_w),
                     .scan_mode(scan_mode)
                        );			      
      

   
      assign illegal_instr = (rst_l == 1'b0) ? 1'b0 : ((fpu_active) & (control_signals[51] == 1'b0) & (~control_signals_r[51])) ? 1'b1 : 1'b0;
      
      // For half precision
      assign valid_execution = (rst_l == 1'b0) ? 1'b0 : (illegal_instr) ? 1'b0 : (fpu_active & control_signals[92] & control_signals_r[92] & ~control_signals[91]  & ~control_signals_r[91]) ? 1'b0 : (fpu_active & (control_signals[91] | control_signals_r[91])) ? 1'b1 : 1'b0; 
      
      assign scalar_control = (rst_l == 1'b0) ? 3'b00 : control_signals[2:0];  // Contain the active signals for rs1, rs2, rd
      
      // for half precision
      assign illegal_config = (rst_l == 1'b0) ? 1'b0 : (fpu_active & (control_signals[89] | control_signals[90])) ? 1'b1 :  1'b0;
      
      // Scalar Register address
      assign rs1_address = (rst_l == 1'b0) ? 5'h00 : (valid_execution | control_signals[10]) ? instr[19:15] : 5'h00;
      assign rs2_address = (rst_l == 1'b0) ? 5'h00 : (valid_execution | control_signals[10]) ? instr[24:20] : 5'h00;
      assign rd_address  = (rst_l == 1'b0) ? 5'h00 : (valid_execution | control_signals[10]) ? instr[11:7]  : 5'h00;
      
      // Floating Control
      assign float_control = (rst_l == 1'b0) ? 4'b0000 : control_signals[57:54];  // Contain the active signals for fs1, fs2, fs3 and fd
      // Floating Point Register address
      assign fs1_addr = (rst_l == 1'b0) ? 5'h00 : (valid_execution & control_signals[54]) ? instr[19:15] : 5'h00;
      assign fs2_addr = (rst_l == 1'b0) ? 5'h00 : (valid_execution & control_signals[55]) ? instr[24:20] : 5'h00;
      assign fs3_addr = (rst_l == 1'b0) ? 5'h00 : (valid_execution & control_signals[56]) ? instr[31:27] : 5'h00;
      // Scalar or Vector operation signals
      assign fpu_sel = (rst_l == 1'b0 | illegal_config) ? 3'h0 : (valid_execution & fpu_active & control_signals[51]) ? {control_signals[93:92],control_signals[74]} : (~valid_execution | ~fpu_active | fpu_complete) ? 3'h0 : 3'h0;

      always @(posedge clk) begin
         if(rst_l == 1'b0 | illegal_config) 
         begin
            control_signals_r <= 114'h0;
         end

         else 
         begin
            // Execution Unit Valid signals and operands
            if((valid_execution & control_signals[51] & fpu_active)) 
            begin
               control_signals_r <= control_signals;
            end
            else if((~valid_execution) | ((~fpu_active) & (fpu_complete))) 
            begin
               control_signals_r <= 114'h0;
            end
            else 
            begin
               control_signals_r <= control_signals_r; 
            end
         end
      end

   // FP Execution Operands
   assign fs1_data = (rst_l == 1'b0 | illegal_config) ? {FPLEN{1'b0}} : (valid_execution & control_signals[51] & fpu_active) ? fs1_data_w : (~valid_execution | ~fpu_active | fpu_complete) ? {FPLEN{1'b0}} : {FPLEN{1'b0}};
   
   assign fs2_data = (rst_l == 1'b0 | illegal_config) ? {FPLEN{1'b0}} : (valid_execution & control_signals[51] & fpu_active) ? fs2_data_w : (~valid_execution | ~fpu_active | fpu_complete) ? {FPLEN{1'b0}} : {FPLEN{1'b0}};
   
   assign fs3_data = (rst_l == 1'b0 | illegal_config) ? {FPLEN{1'b0}} : (valid_execution & control_signals[51] & fpu_active) ? fs3_data_w : (~valid_execution | ~fpu_active | fpu_complete) ? {FPLEN{1'b0}} : {FPLEN{1'b0}};
   
   // Scalar Floating point Control Signals
   assign sfpu_op = (rst_l == 1'b0 | illegal_config) ? 24'h0 : (valid_execution & fpu_active & control_signals[51] & control_signals[92]) ? {control_signals[32:31],control_signals[105:98],control_signals[88:75]} : (~valid_execution | ~fpu_active | fpu_complete) ? 24'h0 : 24'h0;
   
   // Floating Rounding mode
   assign fpu_rnd = (rst_l == 1'b0 | illegal_config) ? 3'h0 : (valid_execution & fpu_active & control_signals[51] & control_signals[92]) ? instr[14:12] : (~valid_execution | ~fpu_active | fpu_complete) ? 3'h0 : 3'h0;
   
   // Precision info {half,double,single}
   assign fpu_pre = (rst_l == 1'b0 | illegal_config) ? 3'h0 : (valid_execution & fpu_active & control_signals[51]) ? control_signals[91:89] : (~valid_execution | ~fpu_active | fpu_complete) ? 3'h0 : 3'h0;
   
   // Halt the core when fdiv/fsqrt
   assign halt_req = (rst_l == 1'b0 | illegal_config) ? 1'b0 : (control_signals[78] | control_signals[79]); 
   

  
endmodule
   
     
