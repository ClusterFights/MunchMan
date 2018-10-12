/*
*****************************
* MODULE : top_loopback_tb
*
* Testbnech for the top_loopback module.
*
* Author : Brandon Bloodget
* Create Date : 10/11/2018
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

`timescale 1 ns / 1 ps

module top_loopback_tb;

// Parameters
parameter CLK_FREQUENCY     = 12_000_000;
parameter BAUD              = 115_200;
parameter TEST_VECTOR_WIDTH = 23;

// Inputs (registers)
reg clk_12mhz;
reg reset_n;
reg rxd;
reg en_tick;


// Outputs (wires)
wire txd;
wire [7:0] led;

wire tick;

// Internal wires

// Testbench rxd data
// Test data is 0xAA, 0xBB with start and stop bits added
reg [TEST_VECTOR_WIDTH-1:0] tv_data = 23'b11_1011_1011_011_1010_1010_01;

/*
*****************************
* Instantiations
*****************************
*/
BaudTickGen # (
    .ClkFrequency(CLK_FREQUENCY),
    .Baud(BAUD),
    .Oversampling(1)
) baud_tick_gen_inst (
    .clk(clk_12mhz),
    .enable(en_tick),
    .tick(tick)
);

// DUT
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

/*
*****************************
* Main
*****************************
*/
initial begin
    $dumpfile("top_loopback.vcd");
    $dumpvars(0, top_loopback_tb);
    clk_12mhz = 0;
    reset_n = 1;
    rxd = 1;
    en_tick = 0;

    // Wait 100ns
    #100;
    // Add stimulus here
    @(posedge clk_12mhz);
    reset_n = 0;
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    reset_n = 1;
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    en_tick = 1;
end


// Generate a ~12mhz clk
always begin
    #41 clk_12mhz <= ~clk_12mhz;
end


// Count clock between ticks
reg [9:0] clk_count;
always @ (posedge clk_12mhz)
begin
    if (~reset_n) begin
        clk_count <= 0;
    end else begin
        if (tick) begin
            clk_count <= 0;
        end else begin
            clk_count <= clk_count + 1;
        end
    end
end

// Drive the rxd line
reg [9:0] bit_count = 0;
always @ (posedge tick) begin
    rxd <= tv_data[0];
    tv_data[TEST_VECTOR_WIDTH-1:0] <= {1'b1, tv_data[TEST_VECTOR_WIDTH-2:1]};
    bit_count <= bit_count + 1;
    if (bit_count > TEST_VECTOR_WIDTH+10) begin
        $finish;
    end
end


endmodule


