
`timescale 1 ns / 1 ps

	module md5_hasher_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S_CTRL_AXI
		parameter integer C_S_CTRL_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_CTRL_AXI_ADDR_WIDTH	= 5,

		// Parameters of Axi Slave Bus Interface S_CHAR_AXIS
		parameter integer C_S_CHAR_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S_CTRL_AXI
		input wire  s_ctrl_axi_aclk,
		input wire  s_ctrl_axi_aresetn,
		input wire [C_S_CTRL_AXI_ADDR_WIDTH-1 : 0] s_ctrl_axi_awaddr,
		input wire [2 : 0] s_ctrl_axi_awprot,
		input wire  s_ctrl_axi_awvalid,
		output wire  s_ctrl_axi_awready,
		input wire [C_S_CTRL_AXI_DATA_WIDTH-1 : 0] s_ctrl_axi_wdata,
		input wire [(C_S_CTRL_AXI_DATA_WIDTH/8)-1 : 0] s_ctrl_axi_wstrb,
		input wire  s_ctrl_axi_wvalid,
		output wire  s_ctrl_axi_wready,
		output wire [1 : 0] s_ctrl_axi_bresp,
		output wire  s_ctrl_axi_bvalid,
		input wire  s_ctrl_axi_bready,
		input wire [C_S_CTRL_AXI_ADDR_WIDTH-1 : 0] s_ctrl_axi_araddr,
		input wire [2 : 0] s_ctrl_axi_arprot,
		input wire  s_ctrl_axi_arvalid,
		output wire  s_ctrl_axi_arready,
		output wire [C_S_CTRL_AXI_DATA_WIDTH-1 : 0] s_ctrl_axi_rdata,
		output wire [1 : 0] s_ctrl_axi_rresp,
		output wire  s_ctrl_axi_rvalid,
		input wire  s_ctrl_axi_rready,

		// Ports of Axi Slave Bus Interface S_CHAR_AXIS
		input wire  s_char_axis_aclk,
		input wire  s_char_axis_aresetn,
		output wire  s_char_axis_tready,
		input wire [C_S_CHAR_AXIS_TDATA_WIDTH-1 : 0] s_char_axis_tdata,
		input wire [(C_S_CHAR_AXIS_TDATA_WIDTH/8)-1 : 0] s_char_axis_tstrb,
		input wire  s_char_axis_tlast,
		input wire  s_char_axis_tvalid
	);
// Instantiation of Axi Bus Interface S_CTRL_AXI
	md5_hasher_v1_0_S_CTRL_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S_CTRL_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_CTRL_AXI_ADDR_WIDTH)
	) md5_hasher_v1_0_S_CTRL_AXI_inst (
		.S_AXI_ACLK(s_ctrl_axi_aclk),
		.S_AXI_ARESETN(s_ctrl_axi_aresetn),
		.S_AXI_AWADDR(s_ctrl_axi_awaddr),
		.S_AXI_AWPROT(s_ctrl_axi_awprot),
		.S_AXI_AWVALID(s_ctrl_axi_awvalid),
		.S_AXI_AWREADY(s_ctrl_axi_awready),
		.S_AXI_WDATA(s_ctrl_axi_wdata),
		.S_AXI_WSTRB(s_ctrl_axi_wstrb),
		.S_AXI_WVALID(s_ctrl_axi_wvalid),
		.S_AXI_WREADY(s_ctrl_axi_wready),
		.S_AXI_BRESP(s_ctrl_axi_bresp),
		.S_AXI_BVALID(s_ctrl_axi_bvalid),
		.S_AXI_BREADY(s_ctrl_axi_bready),
		.S_AXI_ARADDR(s_ctrl_axi_araddr),
		.S_AXI_ARPROT(s_ctrl_axi_arprot),
		.S_AXI_ARVALID(s_ctrl_axi_arvalid),
		.S_AXI_ARREADY(s_ctrl_axi_arready),
		.S_AXI_RDATA(s_ctrl_axi_rdata),
		.S_AXI_RRESP(s_ctrl_axi_rresp),
		.S_AXI_RVALID(s_ctrl_axi_rvalid),
		.S_AXI_RREADY(s_ctrl_axi_rready)
	);

// Instantiation of Axi Bus Interface S_CHAR_AXIS
	md5_hasher_v1_0_S_CHAR_AXIS # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S_CHAR_AXIS_TDATA_WIDTH)
	) md5_hasher_v1_0_S_CHAR_AXIS_inst (
		.S_AXIS_ACLK(s_char_axis_aclk),
		.S_AXIS_ARESETN(s_char_axis_aresetn),
		.S_AXIS_TREADY(s_char_axis_tready),
		.S_AXIS_TDATA(s_char_axis_tdata),
		.S_AXIS_TSTRB(s_char_axis_tstrb),
		.S_AXIS_TLAST(s_char_axis_tlast),
		.S_AXIS_TVALID(s_char_axis_tvalid)
	);

	// Add user logic here

	// User logic ends

	endmodule
