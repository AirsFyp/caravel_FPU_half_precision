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

// Include caravel global defines for the number of the user project IO pads 
`include "defines.v"
`define USE_POWER_PINS

`ifdef GL
    // Assume default net type to be wire because GL netlists don't have the wire definitions
    `default_nettype wire
    `include "gl/user_project_wrapper.v"
    `include "gl/user_proj_example.v"
`else
    `include "user_project_wrapper.v"
    `include "user_proj_example.v"
    `include "FPU/beh_lib.v"
    `include "FPU/Dec_gpr_ctl.v"
    `include "FPU/Execution.v"
    `include "FPU/FMADD_Add_Post_Normalization.v"
    `include "FPU/FMADD_exponent_addition.v"
    `include "FPU/FMADD_Exponent_Matching.v"
    `include "FPU/FMADD_extender.v"
    `include "FPU/FMADD_LZD_L0.v"
    `include "FPU/FMADD_LZD_L1.v"
    `include "FPU/FMADD_LZD_L2.v"
    `include "FPU/FMADD_LZD_L3.v"
    `include "FPU/FMADD_LZD_L4.v"
    `include "FPU/FMADD_LZD_main.v"
    `include "FPU/FMADD_mantissa_addition.v"
    `include "FPU/FMADD_mantissa_generator.v"
    `include "FPU/FMADD_mantissa_multiplication.v"
    `include "FPU/FMADD_Mul_Post_Normalization.v"
    `include "FPU/FMADD_rounding_block_Addition.v"
    `include "FPU/FMADD_rounding_block_Multiplication.v"
    `include "FPU/FMADD_Top_Single_Cycle.v"
    `include "FPU/FPU_comparison.v"
    `include "FPU/FPU_CSR.v"
    `include "FPU/FPU_dec_ctl.v"
    `include "FPU/FPU_decode.v"
    `include "FPU/FPU_exu.v"
    `include "FPU/FPU_F2I.v"
    `include "FPU/FPU_Fclass.v"
    `include "FPU/FPU_fpr_ctl.v"
    `include "FPU/FPU_FSM_Control_Decode.v"
    `include "FPU/FPU_FSM_TOP.v"
    `include "FPU/FPU_Input_Validation.v"
    `include "FPU/FPU_move.v"
    `include "FPU/FPU_sign_injection.v"
    `include "FPU/FPU_Too_Single_Cycle.v"
    `include "FPU/I2F_main.v"
    `include "FPU/iccm_controller.v"
    `include "FPU/inst_checker.v"
    `include "FPU/LZD_comb.v"
    `include "FPU/LZD_layer0.v"
    `include "FPU/LZD_layer1.v"
    `include "FPU/LZD_layer2.v"
    `include "FPU/LZD_layer3.v"
    `include "FPU/LZD_layer4.v"
    `include "FPU/LZD_main.v"
    `include "FPU/LZD_mux.v"
    `include "FPU/Main_Decode.v"
    `include "FPU/uart_rx_prob.v"
    `include "FPU/Sky130_SRAM_1kbyte_Memory.v"
     
`endif
