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

#include <defs.h>
#include <stub.c>

void main()
{
   //reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_NOPULL;
   //reg_mprj_io_1 = GPIO_MODE_USER_STD_INPUT_NOPULL;
   //reg_mprj_io_2 = GPIO_MODE_USER_STD_INPUT_NOPULL;
   //reg_mprj_io_3 = GPIO_MODE_USER_STD_INPUT_NOPULL;
   //reg_mprj_io_4 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_5 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  // reg_mprj_io_6 = GPIO_MODE_USER_STD_OUTPUT;
  // reg_mprj_io_7 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_6 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_7 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_8 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_9 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_11 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_17 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_18 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_19 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_20 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_21 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_22 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_24 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_25 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_26 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_27 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_28 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_29 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_30 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_31 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_32 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_33 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_34 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_35 = GPIO_MODE_USER_STD_OUTPUT;
  //reg_mprj_io_36 = GPIO_MODE_USER_STD_OUTPUT;
  
  reg_mprj_io_37 = GPIO_MODE_MGMT_STD_OUTPUT;

  reg_mprj_xfer = 1;
  while(reg_mprj_xfer == 1);

  // Configure LA probes as inputs to the cpu put zero 
  // Configure LA probes as outputs from the cpu put one
  
  reg_la2_oenb = reg_la2_iena =  0x00000002; // 65 bit as input to user proj and output from cpu for reset
  reg_la2_data = 0x00000000; // reset
  reg_la2_data = 0x00000002; 
  reg_la2_oenb = reg_la2_iena =  0x00000000; // 64 anf 65 bit as input to user proj and output from cpu
  	
  //reg_la1_oenb = reg_la1_iena =  0x00000000;
  //reg_la1_data = 0x00000015C; // Clk_per_bit
  
  //reg_la0_oenb = reg_la0_iena = 0x00000002;
  //reg_la0_data = 0x00000000;
  
  // sending mprj ready signal
  reg_mprj_datah = 0x20;

}
