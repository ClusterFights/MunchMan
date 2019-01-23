/*
*****************************
* MODULE : top_data_test
*
* This module test receiving data from the RPI
* over the parallel interface.  It expects
* 256 sequential bytes, starting at 0.
* After 256 bytes if they are all in order
* it sends a 1 back to the RPI, otherwise a 0.
*
* Author : Brandon Bloodget
* Create Date : 1/21/2019
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module top_data_test
(
    input wire clk_100mhz,
    input wire reset_n,

    // rpi parallel bus
    input wire bus_clk,
    inout wire [7:0] bus_data,
    input wire bus_rnw,         // rpi/master perspective

    output reg [3:0] led_out,
    output wire led0_r,         // indicates reset pressed
    output reg led0_g,         // indicates match
    output reg led1_r         // indicates not match
);


/*
*****************************
* Assignments
*****************************
*/

wire reset;

// bus_data out (read)
reg [7:0] bus_data_out;

assign bus_data = (bus_rnw==1) ? bus_data_out : 8'bz;

assign reset = ~reset_n;

assign led0_r = reset;


/*
*****************************
* Main
*****************************
*/

// register the parallel bus
reg bus_clk_reg;
reg bus_rnw_reg;
reg [7:0] bus_data_reg;

always @ (posedge clk_100mhz)
begin
    if (reset) begin
        bus_clk_reg <= 0;
        bus_rnw_reg <= 0;
        bus_data_reg <= 0;
    end else begin
        bus_clk_reg <= bus_clk;
        bus_rnw_reg <= bus_rnw;
        bus_data_reg <= bus_data;
    end
end

// States
localparam IDLE             = 0;
localparam SYNC             = 1;
localparam WAIT_CLOCK_LOW   = 2;
localparam WAIT_CLOCK_HIGH  = 3;
localparam CHECK            = 4;

reg [3:0] state;
reg [7:0] expected_val;

always @ (posedge clk_100mhz)
begin
    if (reset) begin
        state <= IDLE;
        expected_val <= 0;
        bus_data_out <= 0;
        led_out <= 0;
        led0_g <= 0;
        led1_r <= 0;
    end else begin
        case (state)
            IDLE : begin
                bus_data_out <= 1;  // assume pass
                expected_val <= 0;
                state <= SYNC;
            end
            SYNC : begin
                // Wait sync word on data bus
                if (bus_data_reg == 8'h55) begin
                    state <= WAIT_CLOCK_LOW;
                end
            end
            WAIT_CLOCK_LOW : begin
                if (bus_clk_reg == 0) begin
                    state <= WAIT_CLOCK_HIGH;
                end
            end
            WAIT_CLOCK_HIGH : begin
                if (bus_clk_reg == 1) begin
                    state <= CHECK;
                end
            end
            CHECK : begin
                led_out <= bus_data_reg[3:0];
                if (bus_data_reg != expected_val) begin
                    bus_data_out <= 0;  // nope, fail
                    led1_r <= led1_r + 1;
                end else begin
                    // match
                    led0_g <= led0_g + 1;
                end
                if (expected_val == 255) begin
                    led_out[3:0] <= bus_data_out[3:0];
                    state <= IDLE;
                end else begin
                    expected_val <= expected_val + 1;
                    state <= WAIT_CLOCK_LOW;
                end
            end
            /*
            DONE : begin
                if (bus_clk_reg == 1 && bus_rnw_reg ==1) begin
                    led_out[3:0] <= bus_data_out[3:0];
                    state <= IDLE;
                end
            end
            */
            default : begin
                state <= IDLE;
            end
        endcase
    end
end


endmodule

