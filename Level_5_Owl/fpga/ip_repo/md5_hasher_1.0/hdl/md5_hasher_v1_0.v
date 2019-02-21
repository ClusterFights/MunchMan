
`timescale 1 ns / 1 ps

	module md5_hasher_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S_CTRL_AXI_LITE
		parameter integer C_S_CTRL_AXI_LITE_DATA_WIDTH	= 32,
		parameter integer C_S_CTRL_AXI_LITE_ADDR_WIDTH	= 5,

		// Parameters of Axi Slave Bus Interface S_CHAR_AXIS
		parameter integer C_S_CHAR_AXIS_TDATA_WIDTH	= 8,

		// Parameters of Axi Master Bus Interface M_OUT_AXIS
		parameter integer C_M_OUT_AXIS_TDATA_WIDTH	= 8,
		parameter integer C_M_OUT_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S_CTRL_AXI_LITE
		input wire  s_ctrl_axi_lite_aclk,
		input wire  s_ctrl_axi_lite_aresetn,
		input wire [C_S_CTRL_AXI_LITE_ADDR_WIDTH-1 : 0] s_ctrl_axi_lite_awaddr,
		input wire [2 : 0] s_ctrl_axi_lite_awprot,
		input wire  s_ctrl_axi_lite_awvalid,
		output wire  s_ctrl_axi_lite_awready,
		input wire [C_S_CTRL_AXI_LITE_DATA_WIDTH-1 : 0] s_ctrl_axi_lite_wdata,
		input wire [(C_S_CTRL_AXI_LITE_DATA_WIDTH/8)-1 : 0] s_ctrl_axi_lite_wstrb,
		input wire  s_ctrl_axi_lite_wvalid,
		output wire  s_ctrl_axi_lite_wready,
		output wire [1 : 0] s_ctrl_axi_lite_bresp,
		output wire  s_ctrl_axi_lite_bvalid,
		input wire  s_ctrl_axi_lite_bready,
		input wire [C_S_CTRL_AXI_LITE_ADDR_WIDTH-1 : 0] s_ctrl_axi_lite_araddr,
		input wire [2 : 0] s_ctrl_axi_lite_arprot,
		input wire  s_ctrl_axi_lite_arvalid,
		output wire  s_ctrl_axi_lite_arready,
		output wire [C_S_CTRL_AXI_LITE_DATA_WIDTH-1 : 0] s_ctrl_axi_lite_rdata,
		output wire [1 : 0] s_ctrl_axi_lite_rresp,
		output wire  s_ctrl_axi_lite_rvalid,
		input wire  s_ctrl_axi_lite_rready,

		// Ports of Axi Slave Bus Interface S_CHAR_AXIS
		input wire  s_char_axis_aclk,
		input wire  s_char_axis_aresetn,
		output wire  s_char_axis_tready,
		input wire [C_S_CHAR_AXIS_TDATA_WIDTH-1 : 0] s_char_axis_tdata,
		// XXX input wire [(C_S_CHAR_AXIS_TDATA_WIDTH/8)-1 : 0] s_char_axis_tstrb,
		input wire  s_char_axis_tlast,
		input wire  s_char_axis_tvalid,

		// Ports of Axi Master Bus Interface M_OUT_AXIS
		input wire  m_out_axis_aclk,
		input wire  m_out_axis_aresetn,
		output wire  m_out_axis_tvalid,
		output wire [C_M_OUT_AXIS_TDATA_WIDTH-1 : 0] m_out_axis_tdata,
		// XXX output wire [(C_M_OUT_AXIS_TDATA_WIDTH/8)-1 : 0] m_out_axis_tstrb,
		output wire  m_out_axis_tlast,
		input wire  m_out_axis_tready
	);

/*
************************
* Signals
************************
*/

wire [C_S_CTRL_AXI_LITE_ADDR_WIDTH-1:0] slv_reg0;       // CMD
wire [C_S_CTRL_AXI_LITE_ADDR_WIDTH-1:0] slv_reg1_in;    // Status
wire [C_S_CTRL_AXI_LITE_ADDR_WIDTH-1:0] slv_reg2;       // Hash 0 (msb)
wire [C_S_CTRL_AXI_LITE_ADDR_WIDTH-1:0] slv_reg3;       // Hash 1
wire [C_S_CTRL_AXI_LITE_ADDR_WIDTH-1:0] slv_reg4;       // Hash 2
wire [C_S_CTRL_AXI_LITE_ADDR_WIDTH-1:0] slv_reg5;       // Hash 3
wire [C_S_CTRL_AXI_LITE_ADDR_WIDTH-1:0] slv_reg6;       // String Length
wire [C_S_CTRL_AXI_LITE_ADDR_WIDTH-1:0] slv_reg7;       // Number of bytes to process
wire [C_S_CTRL_AXI_LITE_ADDR_WIDTH-1:0] slv_reg8_in;    // Byte match position

wire reset;

wire [31:0] a_ret;
wire [31:0] b_ret;
wire [31:0] c_ret;
wire [31:0] d_ret;
wire [511:0] md5_msg_ret;
wire md5_msg_ret_valid;

wire [447:0] md5_msg;
wire [15:0] md5_length;
wire md5_msg_valid;

wire proc_busy;

/*
************************
* Assignment
************************
*/

assign reset = (~s_ctrl_axi_lite_aresetn) | slv_reg0[0];

// assign status reg
assign slv_reg1_in =  {29'h0, proc_match, proc_done, proc_busy};

/*
************************
* Instantiations
************************
*/


// Instantiation of Axi Bus Interface S_CTRL_AXI_LITE
	md5_hasher_v1_0_S_CTRL_AXI_LITE # ( 
		.C_S_AXI_DATA_WIDTH(C_S_CTRL_AXI_LITE_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_CTRL_AXI_LITE_ADDR_WIDTH)
	) md5_hasher_v1_0_S_CTRL_AXI_LITE_inst (

        // Control registers
        .slv_reg0(slv_reg0),            // Control Reg
        .slv_reg1_in(slv_reg1_in),      // Status Reg
        .slv_reg2(slv_reg2),            // Target Hash 0 Reg (msb)
        .slv_reg3(slv_reg3),            // Target Hash 1 Reg
        .slv_reg4(slv_reg4),            // Target Hash 2 Reg
        .slv_reg5(slv_reg5),            // Target Hash 3 Reg (lsb)
        .slv_reg6(slv_reg6),            // String Length
        .slv_reg7(slv_reg7),            // Extra
        // End Control registers

		.S_AXI_ACLK(s_ctrl_axi_lite_aclk),
		.S_AXI_ARESETN(s_ctrl_axi_lite_aresetn),
		.S_AXI_AWADDR(s_ctrl_axi_lite_awaddr),
		.S_AXI_AWPROT(s_ctrl_axi_lite_awprot),
		.S_AXI_AWVALID(s_ctrl_axi_lite_awvalid),
		.S_AXI_AWREADY(s_ctrl_axi_lite_awready),
		.S_AXI_WDATA(s_ctrl_axi_lite_wdata),
		.S_AXI_WSTRB(s_ctrl_axi_lite_wstrb),
		.S_AXI_WVALID(s_ctrl_axi_lite_wvalid),
		.S_AXI_WREADY(s_ctrl_axi_lite_wready),
		.S_AXI_BRESP(s_ctrl_axi_lite_bresp),
		.S_AXI_BVALID(s_ctrl_axi_lite_bvalid),
		.S_AXI_BREADY(s_ctrl_axi_lite_bready),
		.S_AXI_ARADDR(s_ctrl_axi_lite_araddr),
		.S_AXI_ARPROT(s_ctrl_axi_lite_arprot),
		.S_AXI_ARVALID(s_ctrl_axi_lite_arvalid),
		.S_AXI_ARREADY(s_ctrl_axi_lite_arready),
		.S_AXI_RDATA(s_ctrl_axi_lite_rdata),
		.S_AXI_RRESP(s_ctrl_axi_lite_rresp),
		.S_AXI_RVALID(s_ctrl_axi_lite_rvalid),
		.S_AXI_RREADY(s_ctrl_axi_lite_rready)
	);

// Instantiation of Axi Bus Interface S_CHAR_AXIS
/*
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
*/

// Instantiation of Axi Bus Interface M_OUT_AXIS
/*
	md5_hasher_v1_0_M_OUT_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M_OUT_AXIS_TDATA_WIDTH),
		.C_M_START_COUNT(C_M_OUT_AXIS_START_COUNT)
	) md5_hasher_v1_0_M_OUT_AXIS_inst (
		.M_AXIS_ACLK(m_out_axis_aclk),
		.M_AXIS_ARESETN(m_out_axis_aresetn),
		.M_AXIS_TVALID(m_out_axis_tvalid),
		.M_AXIS_TDATA(m_out_axis_tdata),
		.M_AXIS_TSTRB(m_out_axis_tstrb),
		.M_AXIS_TLAST(m_out_axis_tlast),
		.M_AXIS_TREADY(m_out_axis_tready)
	);
*/


string_process_match string_process_match_inst
(
    .clk(s_char_axis_aclk),
    .reset(reset),

    // cmd_parser
    .proc_start(slv_reg0[1]),   // start processing chars
    .proc_num_bytes(slv_reg7),  // number of char to process
    .proc_data(s_char_axis_tdata),  // 8-bit char data
    .proc_data_valid(s_char_axis_tvalid),

    .proc_match_char_next(m_out_axis_tready),
    .proc_target_hash({slv_reg3, slv_reg4, slv_reg5, slv_reg6}),
    .proc_str_len(slv_reg7[15:0]),     // len in bits, big endian
    .proc_done(proc_done),
    .proc_match(proc_match),
    .proc_byte_pos(slv_reg8_in),
    output wire [7:0] proc_match_char,
    .proc_busy(proc_busy),
    .proc_ready(s_char_axis_tready),

    // MD5 core
    .a_ret(a_ret),
    .b_ret(b_ret),
    .c_ret(c_ret),
    .d_ret(rd_ret),
    .md5_msg_ret(md5_msg_ret),
    .md5_msg_ret_valid(md5_msg_ret_valid),
    .md5_msg(md5_msg),
    .md5_length(md5_length),  // big endian
    .md5_msg_valid(md5_msg_valid)

);

md5core md5core_inst
(
    .clk(s_char_axis_aclk),
    .reset(reset),
    .en(1'b1),

    .m_in(md5_msg),   // [447:0] 
    .length(md5_length),   // [15:0]
    .valid_in(md5_msg_valid),

    .a_out(a_ret),  // [31:0] 
    .b_out(b_ret),
    .c_out(c_ret),
    .d_out(d_ret),
    .m_out(md5_msg_ret),  // [511:0] 
    .valid_out(md5_msg_ret_valid)
);

	// Add user logic here

	// User logic ends

	endmodule
