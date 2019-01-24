/*
*****************************
* MODULE : top_md5
*
* This module implements the md5
* hashing accelerator.
* This version has been modified to use the
* 8-bit parallel interface between the RPI and
* the ArtyS7 board.
*
* Author : Brandon Bloodget
* Modification Date : 01/23/2019 - Add parallel interface.
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module top_md5 #
(
    parameter integer CLK_FREQUENCY = 100_000_000,
    parameter integer BAUD = 12_000_000,
    parameter integer NUM_LEDS = 8
)
(
    input wire clk,
    input wire reset,
    input wire rxd,

    output wire txd,
    output reg  match_led,
    output wire [NUM_LEDS-1:0] led
);

/*
*****************************
* Signals
*****************************
*/

wire locked;

wire tick;

// uart_rx (receive)
wire rxd_data_ready;
wire [7:0] rxd_data;
wire rxd_idle;
wire rxd_endofpacket;

wire proc_start;
wire [15:0] proc_num_bytes;
wire [7:0] proc_data;
wire proc_data_valid;
wire proc_match_char_next;
wire [127:0] proc_target_hash;

wire proc_done;
wire proc_match;
wire [15:0] proc_byte_pos;
wire [7:0] proc_match_char;

wire [31:0] a_ret;
wire [31:0] b_ret;
wire [31:0] c_ret;
wire [31:0] d_ret;
wire [151:0] md5_msg_ret;
wire md5_msg_ret_valid;

wire [151:0] md5_msg;
wire md5_msg_valid;


// uart_tx (transmit)
wire txd_busy;
wire txd_start;
wire [7:0] txd_data;

/*
*****************************
* Instantiations
*****************************
*/

async_receiver # (
    .ClkFrequency(CLK_FREQUENCY),
    .Baud(BAUD)
) async_receiver_inst (
    .clk(clk),
    .RxD(rxd),
    .RxD_data_ready(rxd_data_ready),
    .RxD_data(rxd_data),
    .RxD_idle(rxd_idle),
    .RxD_endofpacket(rxd_endofpacket)
);

async_transmitter # (
    .ClkFrequency(CLK_FREQUENCY),
    .Baud(BAUD)
) async_transmitter_inst (
    .clk(clk),
    .TxD_start(txd_start),
    .TxD_data(txd_data),
    .TxD(txd),
    .TxD_busy(txd_busy)
);

cmd_parser # (
    .NUM_LEDS(NUM_LEDS)
) cmd_parser_inst (
    .clk(clk),
    .reset(reset),

    // uart_rx (receive)
    .rxd_data(rxd_data), // [7:0]
    .rxd_data_ready(rxd_data_ready),

    // uart_tx (transmit)
    .txd_busy(txd_busy),
    .txd_start(txd_start),
    .txd_data(txd_data), // [7:0]

    // char_buff (process)
    .proc_done(proc_done),
    .proc_match(proc_match),
    .proc_byte_pos(proc_byte_pos), // [15:0] 
    .proc_match_char(proc_match_char), // [7:0] 

    .proc_start(proc_start),
    .proc_num_bytes(proc_num_bytes), // [15:0] 
    .proc_data(proc_data), // [7:0] 
    .proc_data_valid(proc_data_valid),
    .proc_match_char_next(proc_match_char_next),
    .proc_target_hash(proc_target_hash), // [127:0] 

    // feedback/debug
    .led(led)    //   
);


string_process_match string_process_match_inst
(
    .clk(clk),
    .reset(reset),

    // cmd_parser
    .proc_start(proc_start),
    .proc_num_bytes(proc_num_bytes), // [15:0] 
    .proc_data(proc_data),      // [7:0] 
    .proc_data_valid(proc_data_valid),
    .proc_match_char_next(proc_match_char_next),
    .proc_target_hash(proc_target_hash),   // [127:0] 

    .proc_done(proc_done),
    .proc_match(proc_match),
    .proc_byte_pos(proc_byte_pos),      // [15:0] 
    .proc_match_char(proc_match_char),    // [7:0] 

    // MD5 core
    .a_ret(a_ret), // [31:0] 
    .b_ret(b_ret),
    .c_ret(c_ret),
    .d_ret(d_ret),
    .md5_msg_ret(md5_msg_ret),    // [151:0] 
    .md5_msg_ret_valid(md5_msg_ret_valid),

    .md5_msg(md5_msg),        // [151:0] 
    .md5_msg_valid(md5_msg_valid)
);

md5core md5core_inst
(
    .clk(clk),
    .reset(reset),
    .en(1'b1),

    .m_in(md5_msg),   // [151:0] 
    .valid_in(md5_msg_valid),

    .a_out(a_ret),  // [31:0] 
    .b_out(b_ret),
    .c_out(c_ret),
    .d_out(d_ret),
    .m_out(md5_msg_ret),  // [151:0] 
    .valid_out(md5_msg_ret_valid)
);

/*
*****************************
* main
*****************************
*/

// Create a pwm signal
reg [16:0] pwm_count;
reg pwm;
always @ (posedge clk)
begin
    if (reset) begin
        pwm_count <= 0;
        pwm <= 0;
    end else begin
        pwm_count <= pwm_count + 1;
        if (pwm_count == 0) begin
            pwm <= ~pwm;
        end
    end
end

// Drive the match_led
reg proc_match_latch;
always @ (posedge clk)
begin
    if (reset) begin
        proc_match_latch <= 0;
        match_led <= 0;
    end else begin
        if (proc_match) begin
            proc_match_latch <= 1;
        end
        if (proc_match_latch) begin
            match_led <= pwm;
        end
    end
end


endmodule

