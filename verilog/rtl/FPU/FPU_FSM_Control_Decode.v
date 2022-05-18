module FPU_FSM(clk,rst_l,Active_Process,Activation_Signal,Memory_Activation,PC,Instruction,Instruction_out,Multi_Cycle);
  input clk,rst_l,Activation_Signal,Active_Process,Multi_Cycle;
  input [31:0]Instruction;
  output Memory_Activation;
  //output [23:0]Output_1_Hot_Encoded_Opcode;
  output reg[31:0]PC;
  output [31:0]Instruction_out;

  //wire [23:0]Uncontrolled_Opcode;
  reg [1:0]State;
  wire [1:0]Next_State;
  wire [4:0]Input_Opcode;
  wire Exception;

  /*
  sfpu[0] = Fadd
  sfpu[1] = Fsubb
  sfpu[2] = Fmul
  sfpu[3] = Fdiv
  sfpu[4] = Fsqrt
  sfpu[5] = Fmin
  sfpu[6] = Fmax
  sfpu[7] = Fmvx
  sfpu[8] = Fmvf
  sfpu[9] = feq
  sfpu[10] = flt
  sfpu[11] = fle
  sfpu[12] = Fmadd
  sfpu[13] = Fmsubb
  sfpu[14] = FCVT.W.P
  sfpu[15] = FCVT.P.W
  sfpu[16] = Fnmsubb
  sfpu[17] = Fnmadd
  sfpu[18] = fsgnj
  sfpu[19] = fsgnjn
  sfpu[20] = fsgnjx
  sfpu[21] = fclass
  sfpu[22] = unsign
  sfpu[23] = sign
  */
  /*
  assign Input_Opcode = Instruction[4:0];

  assign Output_1_Hot_Encoded_Opcode[0] = ~Input_Opcode[4] & ~Input_Opcode[3] & ~Input_Opcode[2] & ~Input_Opcode[1] & ~Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[1] = ~Input_Opcode[4] & ~Input_Opcode[3] & ~Input_Opcode[2] & ~Input_Opcode[1] & Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[2] = ~Input_Opcode[4] & ~Input_Opcode[3] & ~Input_Opcode[2] & Input_Opcode[1] & ~Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[3] = ~Input_Opcode[4] & ~Input_Opcode[3] & ~Input_Opcode[2] & Input_Opcode[1] & Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[4] = ~Input_Opcode[4] & ~Input_Opcode[3] & Input_Opcode[2] & ~Input_Opcode[1] & ~Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[5] = ~Input_Opcode[4] & ~Input_Opcode[3] & Input_Opcode[2] & ~Input_Opcode[1] & Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[6] = ~Input_Opcode[4] & ~Input_Opcode[3] & Input_Opcode[2] & Input_Opcode[1] & ~Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[7] = ~Input_Opcode[4] & ~Input_Opcode[3] & Input_Opcode[2] & Input_Opcode[1] & Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[8] = ~Input_Opcode[4] & Input_Opcode[3] & ~Input_Opcode[2] & ~Input_Opcode[1] & ~Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[9] = ~Input_Opcode[4] & Input_Opcode[3] & ~Input_Opcode[2] & ~Input_Opcode[1] & Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[10] = ~Input_Opcode[4] & Input_Opcode[3] & ~Input_Opcode[2] & Input_Opcode[1] & ~Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[11] = ~Input_Opcode[4] & Input_Opcode[3] & ~Input_Opcode[2] & Input_Opcode[1] & Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[12] = ~Input_Opcode[4] & Input_Opcode[3] & Input_Opcode[2] & ~Input_Opcode[1] & ~Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[13] = ~Input_Opcode[4] & Input_Opcode[3] & Input_Opcode[2] & ~Input_Opcode[1] & Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[14] = ~Input_Opcode[4] & Input_Opcode[3] & Input_Opcode[2] & Input_Opcode[1] & ~Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[15] = ~Input_Opcode[4] & Input_Opcode[3] & Input_Opcode[2] & Input_Opcode[1] & Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[16] = Input_Opcode[4] & ~Input_Opcode[3] & ~Input_Opcode[2] & ~Input_Opcode[1] & ~Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[17] = Input_Opcode[4] & ~Input_Opcode[3] & ~Input_Opcode[2] & ~Input_Opcode[1] & Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[18] = Input_Opcode[4] & ~Input_Opcode[3] & ~Input_Opcode[2] & Input_Opcode[1] & ~Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[19] = Input_Opcode[4] & ~Input_Opcode[3] & ~Input_Opcode[2] & Input_Opcode[1] & Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[20] = Input_Opcode[4] & ~Input_Opcode[3] & Input_Opcode[2] & ~Input_Opcode[1] & ~Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[21] = Input_Opcode[4] & ~Input_Opcode[3] & Input_Opcode[2] & ~Input_Opcode[1] & Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[22] = Input_Opcode[4] & ~Input_Opcode[3] & Input_Opcode[2] & Input_Opcode[1] & ~Input_Opcode[0];
  assign Output_1_Hot_Encoded_Opcode[23] = Input_Opcode[4] & ~Input_Opcode[3] & Input_Opcode[2] & Input_Opcode[1] & Input_Opcode[0];

  //assign Single_Cycle = (Output_1_Hot_Encoded_Opcode[0] | Output_1_Hot_Encoded_Opcode[1] | Output_1_Hot_Encoded_Opcode[2] | Output_1_Hot_Encoded_Opcode[5] | Output_1_Hot_Encoded_Opcode[6] | Output_1_Hot_Encoded_Opcode[7] | Output_1_Hot_Encoded_Opcode[8] | Output_1_Hot_Encoded_Opcode[9] | Output_1_Hot_Encoded_Opcode[10] | Output_1_Hot_Encoded_Opcode[11] | Output_1_Hot_Encoded_Opcode[14] | Output_1_Hot_Encoded_Opcode[15] | Output_1_Hot_Encoded_Opcode[18] | Output_1_Hot_Encoded_Opcode[19] | Output_1_Hot_Encoded_Opcode[20] | Output_1_Hot_Encoded_Opcode[21] | Output_1_Hot_Encoded_Opcode[22] | Output_1_Hot_Encoded_Opcode[23]);
  assign Multi_Cycle = (Output_1_Hot_Encoded_Opcode[3] | Output_1_Hot_Encoded_Opcode[4] | Output_1_Hot_Encoded_Opcode[12] | Output_1_Hot_Encoded_Opcode[13] | Output_1_Hot_Encoded_Opcode[16] | Output_1_Hot_Encoded_Opcode[17]);
  */
  //assign Multi_Cycle = 1'b0;
  assign Memory_Activation = (((~Next_State[1]) & (Next_State[0])) & (Active_Process));
  assign Next_State[0] = (((~State[0]) & (State[1] | Active_Process)) | ((State[1] & State[0]) & ((~Activation_Signal) | (Activation_Signal & (~Multi_Cycle)))));
  assign Next_State[1] = (((~State[1]) & (State[0])) | ((State[1]) & (~State[0])) | (State[1] & State[0] & (~Activation_Signal)));
  assign Instruction_out = (~rst_l) ? 32'h00000000 : (State == 2'b10) ? Instruction : 32'h00000000;
  always @(posedge clk)
    PC <= (~rst_l) ? 32'h00000000 : ((State == 2'b01) ? (PC[31:0] + 4'h4) : (Instruction == 32'h00000010) ? 32'h00000000 : PC);

  //sequential State register block
  always @(posedge clk)
    State <= (~rst_l) ? 2'b00 : Next_State;


  //combinational State assignment block  
  /*always @(posedge clk)
  begin
    if(Next_State==2'b00)
      Output_1_Hot_Encoded_Opcode <= 24'h000000;
    else if(State==2'b01)
      Output_1_Hot_Encoded_Opcode <= Uncontrolled_Opcode;
    else
      Output_1_Hot_Encoded_Opcode <= Uncontrolled_Opcode;
  end*/

  /*initial 
  begin
    $dumpfile("FPU_FSM.vcd");
    $dumpvars(0);
  end*/

endmodule
   

