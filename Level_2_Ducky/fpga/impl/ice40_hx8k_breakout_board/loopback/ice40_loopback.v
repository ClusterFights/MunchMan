/*
*****************************
* MODULE : ice40_loopback
*
* This module is a test of a uart.
* It is configured as a loopback so
* the RX is tied to the TX. The LEDs
* display the received bytes.  This module
* will also allow us to test determine
* the maximum baud rate.
*
* Target Board: iCE40HX-8K Breakout Board.
*
* Author : Brandon Bloodget
*
*****************************
*/
// Force error when implicit net has no type.
`default_nettype none

module ice40_loopback #
(
    parameter integer CLK_FREQUENCY = 96_000_000,
    parameter integer BAUD = 12_000_000,
    parameter integer NUM_LEDS = 8
)
(
    input wire clk_12mhz,
    // reset on J2, short pin 40(gnd) to pin 38(B16)
    // TODO : Need to add internal pullup to reset_n
    input wire reset_n,
    input wire rxd,

    output wire txd,
    output reg [NUM_LEDS-1:0] led
);

/*
*****************************
* Signals
*****************************
*/

wire clk_96mhz;
wire locked;

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

top_loopback #
(
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .BAUD(BAUD),
    .NUM_LEDS(NUM_LEDS)
)
(
    .clk(clk_96mhz),
    .reset(~reset),
    .rxd(rxd),
    .txd(txd),
    .led(led)
);

endmodule

