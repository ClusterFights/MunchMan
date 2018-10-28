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

`define TESTBENCH

module top_loopback_tb;

// Parameters
parameter integer CLK_FREQUENCY = 96_000_000;
parameter integer BAUD = 12_000_000;
parameter integer NUM_LES = 8;
parameter TEST_VECTOR_WIDTH = 23;

// Inputs (registers)
reg clk_96mhz;
reg reset;
reg rxd;
reg en_tick;


// Outputs (wires)
wire txd;
wire [7:0] led;
wire tick;
wire rxd_data_ready;
wire [7:0] rxd_data;
wire txd_busy;

// Internal wires

// Testbench rxd data
// Test data is 0xAA, 0xBB with start and stop bits added
reg [TEST_VECTOR_WIDTH-1:0] tv_data = 23'b11_1011_1011_011_1010_1010_01;

// Expected results
localparam [7:0] rxd_data_ok1 = 8'hAA;
localparam [7:0] rxd_data_ok2 = 8'hBB;

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
    .clk(clk_96mhz),
    .enable(en_tick),
    .tick(tick)
);

// DUT
top_loopback #
(
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .BAUD(BAUD),
    .NUM_LEDS(8)
)
top_loopback_inst (
    // inputs
    .clk(clk_96mhz),
    .reset(reset),
    .rxd(rxd),
    // outputs
    .txd(txd),
    .rxd_data_ready(rxd_data_ready),
    .rxd_data(rxd_data),
    .txd_busy(txd_busy),
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
    clk_96mhz = 0;
    reset = 0;
    rxd = 1;
    en_tick = 0;

    // Wait 100ns
    #100;
    // Add stimulus here
    @(posedge clk_96mhz);
    reset = 1;
    @(posedge clk_96mhz);
    @(posedge clk_96mhz);
    reset = 0;
    @(posedge clk_96mhz);
    @(posedge clk_96mhz);
    en_tick = 1;
end


// Generate a ~96mhz clk
always begin
    #5.2 clk_96mhz <= ~clk_96mhz;
end


// Count clock between ticks
reg [9:0] clk_count;
reg [9:0] clks_per_tick;
always @ (posedge clk_96mhz)
begin
    if (reset) begin
        clk_count <= 0;
    end else begin
        if (tick) begin
            clks_per_tick <= clk_count;
            clk_count <= 1;
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
end

// Check the results
reg [7:0] tb_count;
reg final_send;
always @ (posedge clk_96mhz) begin
    if (reset) begin
        tb_count <= 0;
        final_send <= 0;
    end else begin
        if (rxd_data_ready) begin
            tb_count <= tb_count + 1;
            case (tb_count)
                0 : begin
                    if (rxd_data == rxd_data_ok1) begin
                        $display("rxd_data: %x, expected: %x, PASS",rxd_data,rxd_data_ok1);
                    end else begin
                        $display("rxd_data: %x, expected: %x, FAIL",rxd_data,rxd_data_ok1);
                    end
                end
                1 : begin
                    final_send <= 1;
                    if (rxd_data == rxd_data_ok2) begin
                        $display("rxd_data: %x, expected: %x, PASS",rxd_data,rxd_data_ok2);
                    end else begin
                        $display("rxd_data: %x, expected: %x, FAIL",rxd_data,rxd_data_ok2);
                    end
                    $display("CLK_FREQUENCY: %d, BAUD: %d",CLK_FREQUENCY,BAUD);
                    $display("clks_per_tick: %d",clks_per_tick);
                end
                default : begin
                    $display("rxd_data: %x, expected: NONE, FAIL",rxd_data);
                end
            endcase
        end
    end
end

// Wait for finsih
reg [7:0] extra_clocks;
reg final_send2;
always @ (posedge clk_96mhz) 
begin
    if (reset) begin
        extra_clocks <= 10;
        final_send2 <= 0;
    end else begin
        final_send2 <= final_send;
        if (final_send2) begin
            if (~txd_busy) begin
                extra_clocks <= extra_clocks - 1;
                if (extra_clocks == 0) begin
                    $finish;
                end
            end
        end
    end
end


endmodule


