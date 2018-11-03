/*
*****************************
* MODULE : arty_s7_md5
*
* This module implements the md5
* hashing accelerator.
*
* Target Board: Arty S7-50 Digilent board
*
* Author : Brandon Bloodget
* Create Date : 11/3/2018 
* Status: Development
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module arty_s7_md5 #
(
    parameter integer CLK_FREQUENCY = 100_000_000,
    parameter integer BAUD = 12_000_000,
    parameter integer NUM_LEDS = 4
)
(
    input wire clk_100mhz,
    // reset on J2, short pin 40(gnd) to pin 38(B16)
    // TODO : Need to add internal pullup to reset_n
    input wire reset_n,
    input wire rxd,

    output wire txd,
    output wire [NUM_LEDS-1:0] led
);

/*
*****************************
* Signals
*****************************
*/

wire reset;
assign reset = ~reset_n;


/*
*****************************
* Instantiations
*****************************
*/

top_md5 #
(
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .BAUD(BAUD),
    .NUM_LEDS(NUM_LEDS)
) top_md5_inst
(
    .clk(clk_100mhz),
    .reset(reset),
    .rxd(rxd),

    .txd(txd),
    .led(led)
);


endmodule

