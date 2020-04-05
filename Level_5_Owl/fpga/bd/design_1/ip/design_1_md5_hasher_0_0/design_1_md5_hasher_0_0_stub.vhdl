-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
-- Date        : Fri Feb 22 18:08:31 2019
-- Host        : Beast running 64-bit Ubuntu 18.04.2 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/brandonb/Projects/ClusterFights/MunchMan/Level_5_Owl/fpga/artyZ7/vivado_prj/project_1/project_1.srcs/sources_1/bd/design_1/ip/design_1_md5_hasher_0_0/design_1_md5_hasher_0_0_stub.vhdl
-- Design      : design_1_md5_hasher_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_md5_hasher_0_0 is
  Port ( 
    s_ctrl_axi_lite_aclk : in STD_LOGIC;
    s_ctrl_axi_lite_aresetn : in STD_LOGIC;
    s_ctrl_axi_lite_awaddr : in STD_LOGIC_VECTOR ( 4 downto 0 );
    s_ctrl_axi_lite_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_ctrl_axi_lite_awvalid : in STD_LOGIC;
    s_ctrl_axi_lite_awready : out STD_LOGIC;
    s_ctrl_axi_lite_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_ctrl_axi_lite_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_ctrl_axi_lite_wvalid : in STD_LOGIC;
    s_ctrl_axi_lite_wready : out STD_LOGIC;
    s_ctrl_axi_lite_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_ctrl_axi_lite_bvalid : out STD_LOGIC;
    s_ctrl_axi_lite_bready : in STD_LOGIC;
    s_ctrl_axi_lite_araddr : in STD_LOGIC_VECTOR ( 4 downto 0 );
    s_ctrl_axi_lite_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_ctrl_axi_lite_arvalid : in STD_LOGIC;
    s_ctrl_axi_lite_arready : out STD_LOGIC;
    s_ctrl_axi_lite_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_ctrl_axi_lite_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_ctrl_axi_lite_rvalid : out STD_LOGIC;
    s_ctrl_axi_lite_rready : in STD_LOGIC;
    s_char_axis_aclk : in STD_LOGIC;
    s_char_axis_aresetn : in STD_LOGIC;
    s_char_axis_tready : out STD_LOGIC;
    s_char_axis_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_char_axis_tlast : in STD_LOGIC;
    s_char_axis_tvalid : in STD_LOGIC;
    match_interrupt : out STD_LOGIC
  );

end design_1_md5_hasher_0_0;

architecture stub of design_1_md5_hasher_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "s_ctrl_axi_lite_aclk,s_ctrl_axi_lite_aresetn,s_ctrl_axi_lite_awaddr[4:0],s_ctrl_axi_lite_awprot[2:0],s_ctrl_axi_lite_awvalid,s_ctrl_axi_lite_awready,s_ctrl_axi_lite_wdata[31:0],s_ctrl_axi_lite_wstrb[3:0],s_ctrl_axi_lite_wvalid,s_ctrl_axi_lite_wready,s_ctrl_axi_lite_bresp[1:0],s_ctrl_axi_lite_bvalid,s_ctrl_axi_lite_bready,s_ctrl_axi_lite_araddr[4:0],s_ctrl_axi_lite_arprot[2:0],s_ctrl_axi_lite_arvalid,s_ctrl_axi_lite_arready,s_ctrl_axi_lite_rdata[31:0],s_ctrl_axi_lite_rresp[1:0],s_ctrl_axi_lite_rvalid,s_ctrl_axi_lite_rready,s_char_axis_aclk,s_char_axis_aresetn,s_char_axis_tready,s_char_axis_tdata[7:0],s_char_axis_tlast,s_char_axis_tvalid,match_interrupt";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "md5_hasher_v1_0,Vivado 2018.3";
begin
end;
