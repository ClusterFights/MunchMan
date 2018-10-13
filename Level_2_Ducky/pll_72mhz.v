/**
 * PLL configuration
 *
 * This Verilog module was generated automatically
 * using the icepll tool from the IceStorm project.
 * Use at your own risk.
 *
 * Given input frequency:        12.000 MHz
 * Requested output frequency:   72.000 MHz
 * Achieved output frequency:    72.000 MHz
 */

module pll_72mhz(
	input  clock_in,
	output clock_out,
	output locked
	);

wire clock_internal;

SB_PLL40_CORE #(
		.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0000),		// DIVR =  0
		.DIVF(7'b0101111),	// DIVF = 47
		.DIVQ(3'b011),		// DIVQ =  3
		.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
	) uut (
		.LOCK(locked),
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.REFERENCECLK(clock_in),
		.PLLOUTCORE(clock_internal)
		);

SB_GB clk_gb ( .USER_SIGNAL_TO_GLOBAL_BUFFER(clock_internal)		
                  , .GLOBAL_BUFFER_OUTPUT(clock_out) );

endmodule
