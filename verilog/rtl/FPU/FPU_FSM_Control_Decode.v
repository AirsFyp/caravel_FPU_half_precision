module FPU_FSM(clk,rst_l,Active_Process,Activation_Signal,Memory_Activation,PC,Instruction,Instruction_out,Multi_Cycle);
  input clk,rst_l,Activation_Signal,Active_Process,Multi_Cycle;
  input [31:0]Instruction;
  output Memory_Activation;
  output reg[31:0]PC;
  output [31:0]Instruction_out;

  reg [2:0]State;
  wire [2:0]Next_State;
  wire [4:0]Input_Opcode;
  wire Exception;

  assign Memory_Activation = (((~Next_State[2]) & (~Next_State[1]) & (Next_State[0])) & (Active_Process));
  assign Next_State[0] = ((((~State[2]) & (~State[0])) & (State[0] | Active_Process)) | ((State[2]) & (~State[1]) & (~State[0]) & (~Multi_Cycle) & (Activation_Signal)));
  assign Next_State[1] = (((~State[2]) & (~State[1]) & (State[0])) | ((~State[2]) & (State[1]) & (~State[0])));
  assign Next_State[2] = (((~State[2]) & (State[1]) & (State[0])) | ((State[2]) & (~State[1]) & (~State[0]) & (~Activation_Signal)));
  assign Instruction_out = (~rst_l) ? 32'h00000000 : (State == 3'b010) ? Instruction : 32'h00000000;
  always @(posedge clk)
    PC <= (~rst_l) ? 32'h00000000 : ((State == 3'b001) ? (PC[31:0] + 4'h4) : (Instruction == 32'h00000010) ? 32'h00000000 : PC);

  //sequential State register block
  always @(posedge clk)
    State <= (~rst_l) ? 3'b000 : Next_State;

endmodule
   



