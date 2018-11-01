/*
*****************************
* MODULE : arty_s7_loopback
*
* This module is a test of a uart.
* It is configured as a loopback so
* the RX is tied to the TX. The LEDs
* display the received bytes.  This module
* will also allow us to test determine
* the maximum baud rate.
*
* Target Board: Arty S7 Digilent board
*
* Author : Brandon Bloodget
*
*****************************
*/
// Force error when implicit net has no type.
`default_nettype none

module arty_s7_loopback #
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
* Instantiations
*****************************
*/


top_loopback #
(
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .BAUD(BAUD),
    .NUM_LEDS(NUM_LEDS)
) top_loopback_inst
(
    .clk(clk_100mhz),
    .reset(~reset_n),
    .rxd(rxd),
    .txd(txd),
    .led(led)
);

endmodule

