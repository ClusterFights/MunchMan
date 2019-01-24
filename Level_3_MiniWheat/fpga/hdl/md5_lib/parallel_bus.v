/*
*****************************
* MODULE : parallel_bus
*
* This module implements an 8-bit parallel
* bus for communicating with an FPGA.
* The goal is to use this interface for
* communication between a raspberry pi
* and an ArtyS7 dev board.
*
* Author : Brandon Bloodget
* Creation Date : 01/23/2019
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module par8_receiver
(
    input wire clk,     // fast, like 100mhz
    input wire reset,

    // parallel bus
    input wire bus_clk,
    input wire [7:0] bus_data,
    input wire bus_rnw,     // rpi/master perspective

    // output
    output reg [7:0] rxd_data,  // valid for one clock cycle when rxd_data_ready is asserted.
    output reg rxd_data_ready
);

/*
*****************************
* Main
*****************************
*/

// register the parallel bus
reg bus_clk_reg1;
reg bus_rnw_reg1;
reg [7:0] bus_data_reg1;

reg bus_clk_reg2;
reg bus_rnw_reg2;
reg [7:0] bus_data_reg2;

always @ (posedge clk)
begin
    if (reset) begin
        bus_clk_reg1 <= 0;
        bus_rnw_reg1 <= 0;
        bus_data_reg1 <= 0;

        bus_clk_reg2 <= 0;
        bus_rnw_reg2 <= 0;
        bus_data_reg2 <= 0;
    end else begin
        bus_clk_reg1 <= bus_clk;
        bus_rnw_reg1 <= bus_rnw;
        bus_data_reg1 <= bus_data;

        bus_clk_reg2 <= bus_clk_reg1;
        bus_rnw_reg2 <= bus_rnw_reg1;
        bus_data_reg2 <= bus_data_reg1;
    end
end

// output logic
always @ (posedge clk)
begin
    if (reset) begin
        rxd_data <= 0;
        rxd_data_ready <= 0;
    end else begin
        // Check for positive edge on bus_clk and write direction
        if (bus_clk_reg1 && !bus_clk_reg2 && !bus_rnw_reg1) begin
            rxd_data <= bus_data_reg1;
            rxd_data_ready <= 1;
        end else begin
            rxd_data_ready <= 0;
        end
    end
end


endmodule

