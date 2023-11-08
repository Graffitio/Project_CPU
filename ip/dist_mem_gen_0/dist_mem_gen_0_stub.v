// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Mon Oct 16 15:33:32 2023
// Host        : DESKTOP-CPLDPO1 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               f:/Ian_Jung/workplace/cora_z7/cora_cpu_2019/cora_cpu_2019/cora_cpu_2019.srcs/sources_1/ip/dist_mem_gen_0/dist_mem_gen_0_stub.v
// Design      : dist_mem_gen_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z007sclg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_13,Vivado 2019.2" *)
module dist_mem_gen_0(a, qspo_ce, spo)
/* synthesis syn_black_box black_box_pad_pin="a[7:0],qspo_ce,spo[7:0]" */;
  input [7:0]a;
  input qspo_ce;
  output [7:0]spo;
endmodule
