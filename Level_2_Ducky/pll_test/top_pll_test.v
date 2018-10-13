/*
*****************************
* MODULE : top_pll_test
*
* This module tests the instantiation
* of a pll module that was created
* using the iCEcube2 "configure PLL Module"
* wizard.  Will the open source tools
* yosys and arachne-pnr be able to handle it?
* Lets find out.
*
* Target Board: iCE40HX-8K Breakout Board.
*
* Author : Brandon Bloodget
* Create Date : 10/12/2018
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module top_pll_test
(
    input wire clk_12mhz,
    input wire reset_n,

    output wire led
);

/*
*****************************
* Signals
*****************************
*/

wire clk_72mhz;

/*
*****************************
* Instantiations
*****************************
*/

pll_72mhz pll_72mhz_inst (
    .clock_in(clk_12mhz),
    .clock_out(clk_72mhz),
    .locked(led)
);


endmodule

