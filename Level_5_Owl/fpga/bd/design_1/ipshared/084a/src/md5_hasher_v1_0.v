/*
*****************************
* MODULE : md5_hasher_v1_0.v
*
* MD5 Hasher for Cluster Fighting with an AXI interface.
*
* Author : Brandon Blodget
*
* Created: 02/21/2019
*
*****************************
*/
`timescale 1 ns / 1 ps

// Force error when implicit net has no type.
`default_nettype none

	module md5_hasher_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S_CTRL_AXI_LITE
		parameter integer C_S_CTRL_AXI_LITE_DATA_WIDTH	= 32,
		parameter integer C_S_CTRL_AXI_LITE_ADDR_WIDTH	= 5,

		// Parameters of Axi Slave Bus Interface S_CHAR_AXIS
		parameter integer C_S_CHAR_AXIS_TDATA_WIDTH	= 8

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
		
		// Match Interrupt
		output reg match_interrupt
	);

/*
************************
* Signals
************************
*/

wire [C_S_CTRL_AXI_LITE_DATA_WIDTH-1:0] slv_reg0;       // CMD
wire [C_S_CTRL_AXI_LITE_DATA_WIDTH-1:0] slv_reg1_in;    // Status
wire [C_S_CTRL_AXI_LITE_DATA_WIDTH-1:0] slv_reg2;       // Hash 0 (msb)
wire [C_S_CTRL_AXI_LITE_DATA_WIDTH-1:0] slv_reg3;       // Hash 1
wire [C_S_CTRL_AXI_LITE_DATA_WIDTH-1:0] slv_reg4;       // Hash 2
wire [C_S_CTRL_AXI_LITE_DATA_WIDTH-1:0] slv_reg5;       // Hash 3
wire [C_S_CTRL_AXI_LITE_DATA_WIDTH-1:0] slv_reg6;       // String Length
wire [C_S_CTRL_AXI_LITE_DATA_WIDTH-1:0] slv_reg7_in;    // Byte match position

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

wire proc_match;
wire proc_done;

wire clear_match_interrupt;

/*
************************
* Assignment
************************
*/

assign reset = (~s_ctrl_axi_lite_aresetn) | slv_reg0[0];

// assign status reg
assign slv_reg1_in =  {29'h0, match_interrupt, proc_done, proc_busy};

assign clear_match_interrupt = slv_reg0[2];

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
        .slv_reg7_in(slv_reg7_in),         // Byte match position
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



string_process_match string_process_match_inst
(
    .clk(s_char_axis_aclk),
    .reset(reset),

    // cmd_parser
    .proc_start(slv_reg0[1]),   // start processing chars
    .proc_data(s_char_axis_tdata),  // 8-bit char data
    .proc_data_valid(s_char_axis_tvalid),
    .proc_ready(s_char_axis_tready),
    .proc_last(s_char_axis_tlast),
    // XXX .proc_num_bytes(),  // NOT USED

    .proc_match_char_next(1'b0),    // NOT USED
    .proc_target_hash({slv_reg2, slv_reg3, slv_reg4, slv_reg5}),
    .proc_str_len(slv_reg6[15:0]),     // len in bits, big endian
    .proc_done(proc_done),
    .proc_match(proc_match),
    .proc_byte_pos(slv_reg7_in),  // match_pos
    // XXX .proc_match_char(),      // NOT USED
    .proc_busy(proc_busy),

    // MD5 core
    .a_ret(a_ret),
    .b_ret(b_ret),
    .c_ret(c_ret),
    .d_ret(d_ret),
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

// Handle latching the match_interrupt on the rising edge
// of proc_match.
// Clear when clear_match_interrupt asserted.
reg prev_proc_match;
always @ (posedge s_ctrl_axi_lite_aclk)
begin
    if (reset) begin
        match_interrupt <= 0;
        prev_proc_match <= 0;
    end else begin
        prev_proc_match <= proc_match;
        if (proc_match && !prev_proc_match) begin
            match_interrupt <= 1;
        end
        if (clear_match_interrupt) begin
            match_interrupt <= 0;
        end 
    end
end
	// User logic ends

	endmodule
