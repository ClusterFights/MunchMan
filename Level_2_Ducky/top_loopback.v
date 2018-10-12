/*
*****************************
* MODULE : top_loopback
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

module top_loopback #
(
    parameter integer CLK_FREQUENCY = 12_000_000,
    parameter integer BAUD = 115_200
)
(
    input wire clk_12mhz,
    // reset on J2, short pin 40(gnd) to pin 38(B16)
    // TODO : Need to add internal pullup to reset_n
    input wire reset_n,
    input wire rxd,

    output wire txd,
    output reg [7:0] led
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

async_receiver # (
    .ClkFrequency(CLK_FREQUENCY),
    .Baud(BAUD)
) async_receiver_inst (
    .clk(clk_12mhz),
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
    .clk(clk_12mhz),
    .TxD_start(rxd_data_ready),
    .TxD_data(rxd_data),
    .TxD(txd),
    .TxD_busy(txd_busy)
);

/*
*****************************
* Main
*****************************
*/

// Show received data on leds.
always @ (posedge clk_12mhz)
begin
    if (~reset_n) begin
        led <= 0;
    end else begin
        if (rxd_data_ready) begin
            led <= rxd_data;
        end
    end
end

endmodule

