/*
*****************************
* MODULE : hash_op_tb
*
* Testbench for the hash_op module.
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

module hash_op_tb;

// Inputs (registers)
reg clk_12mhz;
reg reset;
reg en;


// Outputs (wires)
wire [31:0] a_out;
wire [31:0] b_out;
wire [31:0] c_out;
wire [31:0] d_out;

/*
*****************************
* Instantiation (DUT)
*****************************
*/

// Simulation of stage/index 0.
hash_op #
(
    .index(0),
    .s(7),
    .k(32'hd76aa478)
) hash_op_inst
(
    .clk(clk_12mhz),
    .reset(reset),
    .en(en),

    // Initial values of a,b,c,d
    .a(32'h67452301),
    .b(32'hefcdab89),
    .c(32'h98badcfe),
    .d(32'h10325476),
    // m is a 16th of the full message
    // higher level code pass in the
    // correct part for this "index"
    // For now assume in little endian format.
    .m(32'h20656854),

    .a_out(a_out),
    .b_out(b_out),
    .c_out(c_out),
    .d_out(d_out)
);

/*
*****************************
* Main
*****************************
*/
initial begin
    $dumpfile("hash_op.vcd");
    $dumpvars;
    clk_12mhz = 0;
    reset = 0;
    en = 0;

    // Wait 100ns
    #100;
    // Add stimulus here
    @(posedge clk_12mhz);
    reset = 1;
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    reset = 0;
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    en = 1;
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    $finish;
end


// Generate a ~12mhz clk
always begin
    #41 clk_12mhz <= ~clk_12mhz;
end

endmodule

