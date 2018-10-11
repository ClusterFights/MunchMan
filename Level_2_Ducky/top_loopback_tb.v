/*
*****************************
* MODULE : top_loopback_tb
*
* Testbnech for the top_loopback module.
*
* Author : Brandon Bloodget
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

`timescale 1 ns / 1 ps

module top_loopback_tb;

// Parameters
parameter integer CLK_FREQUENCY = 12_000_000;
parameter integer BAUD = 115_200;

// Inputs (registers)
reg clk_12mhz;
reg reset_n;
reg rxd;

// Outputs (wires)
wire txd;
wire [7:0] led;

// Instantiate DUT
top_loopback #
(
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .BAUD(BAUD)
)
top_loopback_inst (
    // inputs
    .clk_12mhz(clk_12mhz),
    .reset_n(reset_n),
    .rxd(rxd),
    // outputs
    .txd(txd),
    .led(led)
);

// Testbench
initial begin
    $dumpfile("top_loopback.vcd");
    $dumpvars(0, top_loopback_inst);
    clk_12mhz = 0;
    reset_n = 1;
    rxd = 1;

    // Wait 100ns
    #100;
    // Add stimulus here
    @(posedge clk_12mhz);
    reset_n = 0;
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    reset_n = 1;
    #8200;
    $finish;
end


// Generate a ~12mhz clk
always begin
    #41 clk_12mhz <= ~clk_12mhz;
end


endmodule


