/*
*****************************
* MODULE : top_md5
*
* This module implements the md5
* hashing accelerator.
*
* Target Board: iCE40HX-8K Breakout Board.
*
* Author : Brandon Bloodget
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module top_md5 #
(
    parameter integer CLK_FREQUENCY = 96_000_000,
    parameter integer BAUD = 12_000_000
)
(
    input wire clk_12mhz,
    // reset on J2, short pin 40(gnd) to pin 38(B16)
    // TODO : Need to add internal pullup to reset_n
    input wire reset_n,
    input wire rxd,

    output wire txd,
    output reg [0:7] led
);

/*
*****************************
* Signals
*****************************
*/

wire tick;

wire rxd_data_ready;
wire [7:0] rxd_data;
wire rxd_idle;
wire rxd_endofpacket;

wire txd_busy;


/*
*****************************
* Instantiations
*****************************
*/

pll_96mhz pll_96mhz_inst (
    .clock_in(clk_12mhz),
    .clock_out(clk_96mhz),
    .locked(locked)
);

async_receiver # (
    .ClkFrequency(CLK_FREQUENCY),
    .Baud(BAUD)
) async_receiver_inst (
    .clk(clk_96mhz),
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
    .clk(clk_96mhz),
    .TxD_start(rxd_data_ready),
    .TxD_data(rxd_data),
    .TxD(txd),
    .TxD_busy(txd_busy)
);


endmodule
