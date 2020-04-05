// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Fri Feb 22 18:08:31 2019
// Host        : Beast running 64-bit Ubuntu 18.04.2 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/brandonb/Projects/ClusterFights/MunchMan/Level_5_Owl/fpga/artyZ7/vivado_prj/project_1/project_1.srcs/sources_1/bd/design_1/ip/design_1_md5_hasher_0_0/design_1_md5_hasher_0_0_stub.v
// Design      : design_1_md5_hasher_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "md5_hasher_v1_0,Vivado 2018.3" *)
module design_1_md5_hasher_0_0(s_ctrl_axi_lite_aclk, 
  s_ctrl_axi_lite_aresetn, s_ctrl_axi_lite_awaddr, s_ctrl_axi_lite_awprot, 
  s_ctrl_axi_lite_awvalid, s_ctrl_axi_lite_awready, s_ctrl_axi_lite_wdata, 
  s_ctrl_axi_lite_wstrb, s_ctrl_axi_lite_wvalid, s_ctrl_axi_lite_wready, 
  s_ctrl_axi_lite_bresp, s_ctrl_axi_lite_bvalid, s_ctrl_axi_lite_bready, 
  s_ctrl_axi_lite_araddr, s_ctrl_axi_lite_arprot, s_ctrl_axi_lite_arvalid, 
  s_ctrl_axi_lite_arready, s_ctrl_axi_lite_rdata, s_ctrl_axi_lite_rresp, 
  s_ctrl_axi_lite_rvalid, s_ctrl_axi_lite_rready, s_char_axis_aclk, s_char_axis_aresetn, 
  s_char_axis_tready, s_char_axis_tdata, s_char_axis_tlast, s_char_axis_tvalid, 
  match_interrupt)
/* synthesis syn_black_box black_box_pad_pin="s_ctrl_axi_lite_aclk,s_ctrl_axi_lite_aresetn,s_ctrl_axi_lite_awaddr[4:0],s_ctrl_axi_lite_awprot[2:0],s_ctrl_axi_lite_awvalid,s_ctrl_axi_lite_awready,s_ctrl_axi_lite_wdata[31:0],s_ctrl_axi_lite_wstrb[3:0],s_ctrl_axi_lite_wvalid,s_ctrl_axi_lite_wready,s_ctrl_axi_lite_bresp[1:0],s_ctrl_axi_lite_bvalid,s_ctrl_axi_lite_bready,s_ctrl_axi_lite_araddr[4:0],s_ctrl_axi_lite_arprot[2:0],s_ctrl_axi_lite_arvalid,s_ctrl_axi_lite_arready,s_ctrl_axi_lite_rdata[31:0],s_ctrl_axi_lite_rresp[1:0],s_ctrl_axi_lite_rvalid,s_ctrl_axi_lite_rready,s_char_axis_aclk,s_char_axis_aresetn,s_char_axis_tready,s_char_axis_tdata[7:0],s_char_axis_tlast,s_char_axis_tvalid,match_interrupt" */;
  input s_ctrl_axi_lite_aclk;
  input s_ctrl_axi_lite_aresetn;
  input [4:0]s_ctrl_axi_lite_awaddr;
  input [2:0]s_ctrl_axi_lite_awprot;
  input s_ctrl_axi_lite_awvalid;
  output s_ctrl_axi_lite_awready;
  input [31:0]s_ctrl_axi_lite_wdata;
  input [3:0]s_ctrl_axi_lite_wstrb;
  input s_ctrl_axi_lite_wvalid;
  output s_ctrl_axi_lite_wready;
  output [1:0]s_ctrl_axi_lite_bresp;
  output s_ctrl_axi_lite_bvalid;
  input s_ctrl_axi_lite_bready;
  input [4:0]s_ctrl_axi_lite_araddr;
  input [2:0]s_ctrl_axi_lite_arprot;
  input s_ctrl_axi_lite_arvalid;
  output s_ctrl_axi_lite_arready;
  output [31:0]s_ctrl_axi_lite_rdata;
  output [1:0]s_ctrl_axi_lite_rresp;
  output s_ctrl_axi_lite_rvalid;
  input s_ctrl_axi_lite_rready;
  input s_char_axis_aclk;
  input s_char_axis_aresetn;
  output s_char_axis_tready;
  input [7:0]s_char_axis_tdata;
  input s_char_axis_tlast;
  input s_char_axis_tvalid;
  output match_interrupt;
endmodule
