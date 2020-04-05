// (c) Copyright 1995-2019 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: user.org:user:md5_hasher:1.0
// IP Revision: 10

(* X_CORE_INFO = "md5_hasher_v1_0,Vivado 2018.3" *)
(* CHECK_LICENSE_TYPE = "design_1_md5_hasher_0_0,md5_hasher_v1_0,{}" *)
(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_md5_hasher_0_0 (
  s_ctrl_axi_lite_aclk,
  s_ctrl_axi_lite_aresetn,
  s_ctrl_axi_lite_awaddr,
  s_ctrl_axi_lite_awprot,
  s_ctrl_axi_lite_awvalid,
  s_ctrl_axi_lite_awready,
  s_ctrl_axi_lite_wdata,
  s_ctrl_axi_lite_wstrb,
  s_ctrl_axi_lite_wvalid,
  s_ctrl_axi_lite_wready,
  s_ctrl_axi_lite_bresp,
  s_ctrl_axi_lite_bvalid,
  s_ctrl_axi_lite_bready,
  s_ctrl_axi_lite_araddr,
  s_ctrl_axi_lite_arprot,
  s_ctrl_axi_lite_arvalid,
  s_ctrl_axi_lite_arready,
  s_ctrl_axi_lite_rdata,
  s_ctrl_axi_lite_rresp,
  s_ctrl_axi_lite_rvalid,
  s_ctrl_axi_lite_rready,
  s_char_axis_aclk,
  s_char_axis_aresetn,
  s_char_axis_tready,
  s_char_axis_tdata,
  s_char_axis_tlast,
  s_char_axis_tvalid,
  match_interrupt
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_ctrl_axi_lite_aclk, ASSOCIATED_BUSIF s_ctrl_axi_lite, ASSOCIATED_RESET s_ctrl_axi_lite_aresetn, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_ctrl_axi_lite_aclk CLK" *)
input wire s_ctrl_axi_lite_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_ctrl_axi_lite_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_ctrl_axi_lite_aresetn RST" *)
input wire s_ctrl_axi_lite_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite AWADDR" *)
input wire [4 : 0] s_ctrl_axi_lite_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite AWPROT" *)
input wire [2 : 0] s_ctrl_axi_lite_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite AWVALID" *)
input wire s_ctrl_axi_lite_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite AWREADY" *)
output wire s_ctrl_axi_lite_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite WDATA" *)
input wire [31 : 0] s_ctrl_axi_lite_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite WSTRB" *)
input wire [3 : 0] s_ctrl_axi_lite_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite WVALID" *)
input wire s_ctrl_axi_lite_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite WREADY" *)
output wire s_ctrl_axi_lite_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite BRESP" *)
output wire [1 : 0] s_ctrl_axi_lite_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite BVALID" *)
output wire s_ctrl_axi_lite_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite BREADY" *)
input wire s_ctrl_axi_lite_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite ARADDR" *)
input wire [4 : 0] s_ctrl_axi_lite_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite ARPROT" *)
input wire [2 : 0] s_ctrl_axi_lite_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite ARVALID" *)
input wire s_ctrl_axi_lite_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite ARREADY" *)
output wire s_ctrl_axi_lite_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite RDATA" *)
output wire [31 : 0] s_ctrl_axi_lite_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite RRESP" *)
output wire [1 : 0] s_ctrl_axi_lite_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite RVALID" *)
output wire s_ctrl_axi_lite_rvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_ctrl_axi_lite, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 5, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, NUM_RE\
AD_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_ctrl_axi_lite RREADY" *)
input wire s_ctrl_axi_lite_rready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_char_axis_aclk, ASSOCIATED_BUSIF s_char_axis, ASSOCIATED_RESET s_char_axis_aresetn, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_char_axis_aclk CLK" *)
input wire s_char_axis_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_char_axis_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_char_axis_aresetn RST" *)
input wire s_char_axis_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_char_axis TREADY" *)
output wire s_char_axis_tready;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_char_axis TDATA" *)
input wire [7 : 0] s_char_axis_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_char_axis TLAST" *)
input wire s_char_axis_tlast;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_char_axis, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_char_axis TVALID" *)
input wire s_char_axis_tvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME match_interrupt, SENSITIVITY LEVEL_HIGH, PortWidth 1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 match_interrupt INTERRUPT" *)
output wire match_interrupt;

  md5_hasher_v1_0 #(
    .C_S_CTRL_AXI_LITE_DATA_WIDTH(32),
    .C_S_CTRL_AXI_LITE_ADDR_WIDTH(5),
    .C_S_CHAR_AXIS_TDATA_WIDTH(8)
  ) inst (
    .s_ctrl_axi_lite_aclk(s_ctrl_axi_lite_aclk),
    .s_ctrl_axi_lite_aresetn(s_ctrl_axi_lite_aresetn),
    .s_ctrl_axi_lite_awaddr(s_ctrl_axi_lite_awaddr),
    .s_ctrl_axi_lite_awprot(s_ctrl_axi_lite_awprot),
    .s_ctrl_axi_lite_awvalid(s_ctrl_axi_lite_awvalid),
    .s_ctrl_axi_lite_awready(s_ctrl_axi_lite_awready),
    .s_ctrl_axi_lite_wdata(s_ctrl_axi_lite_wdata),
    .s_ctrl_axi_lite_wstrb(s_ctrl_axi_lite_wstrb),
    .s_ctrl_axi_lite_wvalid(s_ctrl_axi_lite_wvalid),
    .s_ctrl_axi_lite_wready(s_ctrl_axi_lite_wready),
    .s_ctrl_axi_lite_bresp(s_ctrl_axi_lite_bresp),
    .s_ctrl_axi_lite_bvalid(s_ctrl_axi_lite_bvalid),
    .s_ctrl_axi_lite_bready(s_ctrl_axi_lite_bready),
    .s_ctrl_axi_lite_araddr(s_ctrl_axi_lite_araddr),
    .s_ctrl_axi_lite_arprot(s_ctrl_axi_lite_arprot),
    .s_ctrl_axi_lite_arvalid(s_ctrl_axi_lite_arvalid),
    .s_ctrl_axi_lite_arready(s_ctrl_axi_lite_arready),
    .s_ctrl_axi_lite_rdata(s_ctrl_axi_lite_rdata),
    .s_ctrl_axi_lite_rresp(s_ctrl_axi_lite_rresp),
    .s_ctrl_axi_lite_rvalid(s_ctrl_axi_lite_rvalid),
    .s_ctrl_axi_lite_rready(s_ctrl_axi_lite_rready),
    .s_char_axis_aclk(s_char_axis_aclk),
    .s_char_axis_aresetn(s_char_axis_aresetn),
    .s_char_axis_tready(s_char_axis_tready),
    .s_char_axis_tdata(s_char_axis_tdata),
    .s_char_axis_tlast(s_char_axis_tlast),
    .s_char_axis_tvalid(s_char_axis_tvalid),
    .match_interrupt(match_interrupt)
  );
endmodule
