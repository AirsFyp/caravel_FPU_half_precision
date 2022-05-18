module FPU_Comparison(rst_l,opcode,Comparator_Input_IEEE_A,Comparator_Input_IEEE_B,Comparator_Output_IEEE,Min_Max_Output_IEEE);
  //Standard Defination For Parameterization
  
  parameter Std = 31; // Means IEEE754 Std 32 Bit Single Precision -1 for bits
  parameter Exp = 7; // Means IEEE754 8 Bit For Exponents in Single Precision -1 for bits
  parameter Man = 22; // Means IEEE754 23 Bit For Mantissa in Single Precision -1 for bits
  
  input [Std : 0] Comparator_Input_IEEE_A, Comparator_Input_IEEE_B; // Std + 1 is for IEEE754 Hidden Bit inclusion
  input [7:0]opcode;// opcode for selections
  input rst_l;
  output [31 : 0] Comparator_Output_IEEE;
  output[Std:0] Min_Max_Output_IEEE;
  
  reg [31 : 0] Comparator_Output_IEEE_reg;
  reg [Std:0] Min_Max_Output_IEEE_reg;
  wire Comparator_Sign_A, Comparator_Sign_B;
  wire [Exp : 0] Comparator_Exp_A, Comparator_Exp_B;
  wire [Man + 1 : 0] Comparator_Mantissa_A, Comparator_Mantissa_B;
  
  
  //==========OPCODES============
  // opcode [0] = feq
  // opcode [1] = fne
  // opcode [2] = flt
  // opcode [3] = fle
  // opcode [4] = fgt
  // opcode [5] = fge
  // opcode [6] = fmin
  // opcode [7] = fmax
  
 //============INPUTS=============
 // Comparator_Input_IEEE_A 
 // Comparator_Input_IEEE_B
 
 //============OUTPUTS============
 // Comparator_Output_IEEE 
 // Min_Max_Output_IEEE
  
 //=================FLAGS========= 
 // INVALID FLAG (NV)
  
    assign Comparator_Sign_A = (rst_l) ? Comparator_Input_IEEE_A[Std] : 1'b0; // Sign Bit Assigning Std + 1 Because it contain IEEE754 hidden bit also
    assign Comparator_Sign_B = (rst_l) ? Comparator_Input_IEEE_B[Std] : 1'b0; // Sign Bit Assigning Std + 1 Because it contain IEEE754 hidden bit also
    assign Comparator_Exp_A = (rst_l) ? Comparator_Input_IEEE_A[Std - 1 : Std - Exp - 1] : {1'b0,{Exp{1'b0}}};
    assign Comparator_Exp_B = (rst_l) ? Comparator_Input_IEEE_B[Std - 1 : Std - Exp - 1] : {1'b0,{Exp{1'b0}}};
    assign Comparator_Mantissa_A = (rst_l) ? {1'b1,Comparator_Input_IEEE_A[Man : 0]} : {1'b0,{Man{1'b0}}};
    assign Comparator_Mantissa_B = (rst_l) ? {1'b1,Comparator_Input_IEEE_B[Man : 0]} : {1'b0,{Man{1'b0}}};
    
    assign Comparator_Output_IEEE = (rst_l==1'b0) ? 32'h00000000 : (opcode[0] == 1'b1) ? ((Comparator_Input_IEEE_A == Comparator_Input_IEEE_B) ? 32'h00000001 : 32'h00000000) : // Equal
                                                                   (opcode[1] == 1'b1) ? ((Comparator_Input_IEEE_A != Comparator_Input_IEEE_B) ? 32'h00000001 : 32'h00000000) : // Not Equal
                                                                   
                                                                   (opcode[2] == 1'b1) ? (((Comparator_Sign_A & Comparator_Sign_B) ? (((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A > Comparator_Mantissa_B))) ? 32'h00000001 : 32'h00000000) : (Comparator_Sign_A < Comparator_Sign_B) ? 32'h00000000 : (Comparator_Sign_A > Comparator_Sign_B) ? 32'h00000001 : (((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A < Comparator_Mantissa_B))) ? 32'h00000001 : 32'h00000000))) : // less than
                                                                   
                                                                   (opcode[3] == 1'b1) ? (((Comparator_Sign_A & Comparator_Sign_B) ? (((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & ((Comparator_Mantissa_A > Comparator_Mantissa_B) | (Comparator_Mantissa_A == Comparator_Mantissa_B)))) ? 32'h00000001 : 32'h00000000) : (Comparator_Sign_A < Comparator_Sign_B) ? 32'h00000000 : (Comparator_Sign_A > Comparator_Sign_B) ? 32'h00000001 : (((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) && ((Comparator_Mantissa_A < Comparator_Mantissa_B) | (Comparator_Mantissa_A == Comparator_Mantissa_B)))) ? 32'h00000001 : 32'h00000000))) : // less and equal 
                                                                   
                                                                   (opcode[4] == 1'b1) ? (((Comparator_Sign_A & Comparator_Sign_B) ? (((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A < Comparator_Mantissa_B))) ? 32'h00000001 : 32'h00000000) : (Comparator_Sign_A > Comparator_Sign_B) ? 32'h00000000 : (Comparator_Sign_A < Comparator_Sign_B) ? 32'h00000001 : (((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A > Comparator_Mantissa_B))) ? 32'h00000001 : 32'h00000000))) : // greater than
                                                                   
                                                                   (opcode[5] == 1'b1) ? (((Comparator_Sign_A & Comparator_Sign_B) ? (((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & ((Comparator_Mantissa_A < Comparator_Mantissa_B) | (Comparator_Mantissa_A == Comparator_Mantissa_B)))) ? 32'h00000001 : 32'h00000000) : (Comparator_Sign_A > Comparator_Sign_B) ? 32'h00000000 : (Comparator_Sign_A < Comparator_Sign_B) ? 32'h00000001 : (((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) && ((Comparator_Mantissa_A > Comparator_Mantissa_B) | (Comparator_Mantissa_A == Comparator_Mantissa_B)))) ? 32'h00000001 : 32'h00000000))) : // greater and equal
                                                                   
                                                                   32'h00000000;
    
    assign Min_Max_Output_IEEE    = (rst_l==1'b0) ? {Std+1{1'b0}} : (opcode[6] == 1'b1) ? (((Comparator_Sign_A & Comparator_Sign_B) ? (((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A > Comparator_Mantissa_B))) ? Comparator_Input_IEEE_A : Comparator_Input_IEEE_B) : (Comparator_Sign_A < Comparator_Sign_B) ? Comparator_Input_IEEE_B : (Comparator_Sign_A > Comparator_Sign_B) ? Comparator_Input_IEEE_A : (((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A < Comparator_Mantissa_B))) ? Comparator_Input_IEEE_A : Comparator_Input_IEEE_B))) : // Fmin 
                                                   		     (opcode[7] == 1'b1) ? (((Comparator_Sign_A & Comparator_Sign_B) ? (((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A < Comparator_Mantissa_B))) ? Comparator_Input_IEEE_A : Comparator_Input_IEEE_B) : (Comparator_Sign_A > Comparator_Sign_B) ? Comparator_Input_IEEE_B : (Comparator_Sign_A < Comparator_Sign_B) ? Comparator_Input_IEEE_A : (((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A > Comparator_Mantissa_B))) ? Comparator_Input_IEEE_A : Comparator_Input_IEEE_B))) : // Fmax
                                                   		     {Std+1{1'b0}};

    
 /* always @(*)
  begin
 */   
    /*if(rst_l == 1'b0)
      begin
        Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000000; // if reset the output will be 32 bit 0
        Min_Max_Output_IEEE_reg = 32'b00000000000000000000000000000000; // if reset the output will be 32 bit 0
      end
    
    
    
    else if (opcode[0] == 1'b1) // A Equal to B
      begin
        if (Comparator_Input_IEEE_A == Comparator_Input_IEEE_B) // if both input is same the output is 32 bit 1 in Equal condition
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;
        else
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000000; //if both input is not same the output is 32 bit 0
      end
    
    else if (opcode[1] == 1'b1) // A Not Equal to B
      begin
        if (Comparator_Input_IEEE_A != Comparator_Input_IEEE_B) //if both input is not same the output is 32 bit 1 in Not Equal condition
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;
        else
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000000;//if both input is same the output is 32 bit 0 in Not Equal condition
      end
    */
   /* else if (opcode[2] == 1'b1) // A Less than B
      begin
        if((Comparator_Sign_A & Comparator_Sign_B)==1) //check when both inputs are Negative 
          begin
            if ((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A > Comparator_Mantissa_B))) // check when both inputs are negative and compare its exponent and mantissa when A is less than B the output is 32 bit 1.
              Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;
            else // else when A is not less than B the output is 32 bit 0's
              Comparator_Output_IEEE_reg = 32'b0000000000000000000000000000000;
          end
        // check when both inputs are Positive and either one input is Negative 
        else if(Comparator_Sign_A < Comparator_Sign_B) // if input B is Negative and its Sign Bit is 1 the output is 32 bit 0's 
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000000;
        else if (Comparator_Sign_A > Comparator_Sign_B)// if input A is Negative and its Sign Bit is 1 the output is 32 bit 1's
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;

        //when both Inputs are Positive then compare its Exponent and Mantissa
        else if ((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A < Comparator_Mantissa_B)))// if Exponent_A is less than Exponent_B the Output is 32 bit 1 and also check when Both Exponents are Equal and Mantissa_A is less than Mantissa_B then the output is 32 bit 1 
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;
        else// else when A is not less than B the output is 32 bit 0's
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000000;
      end
*/
 /*   else if (opcode[3] == 1'b1) // A Less than Equal to B
      begin
        if((Comparator_Sign_A & Comparator_Sign_B)==1)//check when both inputs are Negative 
          begin
            if ((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & ((Comparator_Mantissa_A > Comparator_Mantissa_B) | (Comparator_Mantissa_A == Comparator_Mantissa_B))))// check when both inputs are negative and compare its exponent and mantissa when A is less than Equal to B the output is 32 bit 1.
              Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;
            else // else when A is not less than Equal to B the output is 32 bit 0's
              Comparator_Output_IEEE_reg = 32'b0000000000000000000000000000000;
          end
        // check when both inputs are Positive and either one input is Negative 
        else if(Comparator_Sign_A < Comparator_Sign_B)// if input B is Negative and its Sign Bit is 1 the output is 32 bit 0's 
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000000;
        else if (Comparator_Sign_A > Comparator_Sign_B)// if input A is Negative and its Sign Bit is 1 the output is 32 bit 1's
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;

        //when both Inputs are Positive then compare its Exponent and Mantissa
        else if ((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) && ((Comparator_Mantissa_A < Comparator_Mantissa_B) | (Comparator_Mantissa_A == Comparator_Mantissa_B))))// if Exponent_A is less than Exponent_B the Output is 32 bit 1 and also check when Both Exponents are Equal and Mantissa_A is less than Mantissa_B and also both Mantissa's are Equal then the output is 32 bit 1 
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;
        else // else when A is not less than B the output is 32 bit 0's
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000000;
      end
*/
 /*   else if (opcode[4] == 1'b1) // A Greter than B
      begin
        if((Comparator_Sign_A & Comparator_Sign_B)==1)//check when both inputs are Negative 
          begin
            if ((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A < Comparator_Mantissa_B)))// check when both inputs are negative and compare its exponent and mantissa when A is Greater than B the output is 32 bit 1.
              Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;
            else // else when A is not Greater than B the output is 32 bit 0's
              Comparator_Output_IEEE_reg = 32'b0000000000000000000000000000000;
          end
        // check when both inputs are Positive and either one input is Negative 
        else if(Comparator_Sign_A > Comparator_Sign_B)// if input A is Negative and its Sign Bit is 1 the output is 32 bit 0's 
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000000;
        else if (Comparator_Sign_A < Comparator_Sign_B)// if input B is Negative and its Sign Bit is 1 the output is 32 bit 1's
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;

        //when both Inputs are Positive then compare its Exponent and Mantissa
        else if ((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A > Comparator_Mantissa_B)))// if Exponent_A is Greater than Exponent_B the Output is 32 bit 1 and also check when Both Exponents are Equal and Mantissa_A is Greater than Mantissa_B then the output is 32 bit 1 
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;
        else// else when A is not less than B the output is 32 bit 0's
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000000;

      end
*/
/*    else if (opcode[5] == 1'b1) // A Greater than Equal to B
      begin
        if((Comparator_Sign_A & Comparator_Sign_B)==1)//check when both inputs are Negative 
          begin
            if ((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & ((Comparator_Mantissa_A < Comparator_Mantissa_B) | (Comparator_Mantissa_A == Comparator_Mantissa_B))))// check when both inputs are negative and compare its exponent and mantissa when A is Greater than Equal to B the output is 32 bit 1.
              Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;
            else  // else when A is not Greater than B the output is 32 bit 0's
              Comparator_Output_IEEE_reg = 32'b0000000000000000000000000000000;
          end

        // check when both inputs are Positive and either one input is Negative 
        else if(Comparator_Sign_A > Comparator_Sign_B)// if input A is Negative and its Sign Bit is 1 the output is 32 bit 0's 
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000000;
        else if (Comparator_Sign_A < Comparator_Sign_B)// if input B is Negative and its Sign Bit is 1 the output is 32 bit 1's
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;

        //when both Inputs are Positive then compare its Exponent and Mantissa
        else if ((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) && ((Comparator_Mantissa_A > Comparator_Mantissa_B) | (Comparator_Mantissa_A == Comparator_Mantissa_B))))// if Exponent_A is Greater than Exponent_B the Output is 32 bit 1 and also check when Both Exponents are Equal and Mantissa_A is Greater than Mantissa_B and also both Mantissa's are Equal then the output is 32 bit 1 
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000001;
        else // else when A is not less than B the output is 32 bit 0's
          Comparator_Output_IEEE_reg = 32'b00000000000000000000000000000000;
      end
  */  
   /*else if (opcode[6] == 1'b1) // Min
      begin
        if((Comparator_Sign_A & Comparator_Sign_B)==1)//check when both inputs are Negative 
          begin
            if ((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A > Comparator_Mantissa_B)))// check when both inputs are negative and compare its exponent and mantissa when A is Minimum to B the output is Input A.
              Min_Max_Output_IEEE_reg = Comparator_Input_IEEE_A;
            else // else when A is not Minimum to B the output is Input B.
              Min_Max_Output_IEEE_reg = Comparator_Input_IEEE_B;
          end

        // check when both inputs are Positive and either one input is Negative 
        else if(Comparator_Sign_A < Comparator_Sign_B) // if input B is Negative and its Sign Bit is 1 the output is Input B.
          Min_Max_Output_IEEE_reg = Comparator_Input_IEEE_B;
        else if (Comparator_Sign_A > Comparator_Sign_B) // if input A is Negative and its Sign Bit is 1 the output is Input A.
          Min_Max_Output_IEEE_reg = Comparator_Input_IEEE_A;

        //when both Inputs are Positive then compare its Exponent and Mantissa
        else if ((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A < Comparator_Mantissa_B)))// if Exponent_A is less than Exponent_B the Output is Input A and also check when Both Exponents are Equal and Mantissa_A is less than Mantissa_B then the output is Input A.
          Min_Max_Output_IEEE_reg = Comparator_Input_IEEE_A;
        else// else when A is not Minimum to B the output is Input B.
          Min_Max_Output_IEEE_reg = Comparator_Input_IEEE_B;
      end

  */          
  /*  else if (opcode[7] == 1'b1) // Max
      begin
        if((Comparator_Sign_A & Comparator_Sign_B)==1)//check when both inputs are Negative 
          begin
            if ((Comparator_Exp_A < Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A < Comparator_Mantissa_B)))// check when both inputs are negative and compare its exponent and mantissa when A is Maximum than B the output is Input A.
              Min_Max_Output_IEEE_reg = Comparator_Input_IEEE_A;
            else // else when A is not Maximum to B the output is Input B.
              Min_Max_Output_IEEE_reg = Comparator_Input_IEEE_B;
          end
        //when both Inputs are Positive then compare its Exponent and Mantissa
        else if(Comparator_Sign_A > Comparator_Sign_B) // if input A is Negative and its Sign Bit is 1 the output is Input B.
          Min_Max_Output_IEEE_reg = Comparator_Input_IEEE_B;
        else if (Comparator_Sign_A < Comparator_Sign_B) // if input B is Negative and its Sign Bit is 1 the output is Input A.
          Min_Max_Output_IEEE_reg = Comparator_Input_IEEE_A;

        //when both Inputs are Positive then compare its Exponent and Mantissa
        else if ((Comparator_Exp_A > Comparator_Exp_B) | ((Comparator_Exp_A == Comparator_Exp_B) & (Comparator_Mantissa_A > Comparator_Mantissa_B)))// if Exponent_A is Greater than Exponent_B the Output is Input A and also check when Both Exponents are Equal and Mantissa_A is Greater than Mantissa_B then the output is Input A. 
          Min_Max_Output_IEEE_reg = Comparator_Input_IEEE_A;
        else// else when A is not Maximum to B the output is Input B.
          Min_Max_Output_IEEE_reg = Comparator_Input_IEEE_B;
      end
  end
*/
endmodule
