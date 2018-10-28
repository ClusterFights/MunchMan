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
* Author : Brandon Bloodget
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module top_loopback #
(
    parameter integer CLK_FREQUENCY = 96_000_000,
    parameter integer BAUD = 12_000_000,
    parameter integer NUM_LEDS = 8
)
(
    input wire clk,
    input wire reset,
    input wire rxd,

    output wire txd,
`ifdef TESTBENCH
    output wire rxd_data_ready,
    output wire [7:0] rxd_data,
    output wire txd_busy,
`endif
    output reg [NUM_LEDS-1:0] led
);

/*
*****************************
* Signals
*****************************
*/

`ifndef TESTBENCH
wire rxd_data_ready;
wire [7:0] rxd_data;
wire txd_busy;
`endif


wire rxd_idle;
wire rxd_endofpacket;

reg txd_start;
reg [7:0] rxd_data2;
reg sent2;

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
    .TxD_data(rxd_data2),
    .TxD(txd),
    .TxD_busy(txd_busy)
);

/*
*****************************
* Main
*****************************
*/

// Register the received data.  Wait
// for transmitter to be not busy before sending
always @ (posedge clk) 
begin
    if (reset) begin
        txd_start <= 0;
        rxd_data2 <= 0;
        sent2 <= 1;
    end else begin
        txd_start <= 0;
        if (rxd_data_ready) begin
            rxd_data2 <= rxd_data;
            sent2 <= 0;
        end
        if (~sent2 && ~txd_busy) begin
            sent2 <= 1;
            txd_start <= 1;
        end
    end
end

// Show received data on leds.
always @ (posedge clk)
begin
    if (reset) begin
        led <= 0;
    end else begin
        if (rxd_data_ready) begin
            led <= rxd_data;
        end
    end
end

endmodule

