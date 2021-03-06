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
* 
* Updates:
* 01/25/2019 : Updated to support parallel 8 interface
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module arty_s7_md5 #
(
    parameter integer NUM_LEDS = 4
)
(
    input wire clk_100mhz,
    input wire reset_n,

    // rpi parallel bus
    input wire bus_clk,
    inout wire [15:0] bus_data,
    input wire bus_rnw,         // rpi/master perspective

    output wire bus_done,
    output wire bus_match,
    output wire led0_g,
    output wire led0_r,         // indicates reset pressed
    output wire led0_b,         // not locked
    output wire [NUM_LEDS-1:0] led
);

/*
*****************************
* Signals & Assignments
*****************************
*/

wire reset;

assign reset = ~reset_n;
assign led0_r = reset;

wire clk_150mhz;
wire locked;

assign led0_b = ~locked;


/*
*****************************
* Instantiations
*****************************
*/

clk_wiz_1 clk_wiz_1_inst
(
    .clk_in1(clk_100mhz),
    .clk_out1(clk_150mhz),
    .locked(locked)
);

top_md5 #
(
    .NUM_LEDS(NUM_LEDS)
) top_md5_inst
(
    .clk(clk_150mhz),
    .reset(reset),
    .bus_clk(bus_clk),
    .bus_data(bus_data),
    .bus_rnw(bus_rnw),         // rpi/master perspective

    .bus_done(bus_done),
    .bus_match(bus_match),
    .match_led(led0_g),
    .led(led)
);


endmodule

