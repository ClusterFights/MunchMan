/*
*****************************
* MODULE : md5core_tb
*
* Testbench for the md5core module.
*
* Author : Brandon Bloodget
* Create Date : 10/16/2018
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

`timescale 1 ns / 1 ps

`define TESTBENCH

module md5core_tb;

// Inputs (registers)
reg clk_12mhz;
reg reset;
reg en;
reg valid_in;


// Outputs (wires)
wire [31:0] a_out;
wire [31:0] b_out;
wire [31:0] c_out;
wire [31:0] d_out;
wire valid_out;

// Define the message
// mesg="The quick brown fox jumps over the lazy dog" plus required padding.
wire [511:0] mesg = 512'h54686520_71756963_6b206272_6f776e20_666f7820_6a756d70_73206f76_65722074_6865206c_617a7920_646f6780_00000000_00000000_00000000_58010000_00000000;

/*
*****************************
* Instantiation (DUT)
*****************************
*/

md5core md5core_inst
(
    .clk(clk_12mhz),
    .reset(reset),
    .en(en),

    .mesg(mesg),
    .valid_in(valid_in),

    .a_out(a_out),
    .b_out(b_out),
    .c_out(c_out),
    .d_out(d_out),
    .valid_out(valid_out)
);

/*
*****************************
* Main
*****************************
*/
initial begin
    $dumpfile("md5core.vcd");
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
end


// Generate a ~12mhz clk
always begin
    #41 clk_12mhz <= ~clk_12mhz;
end


// Run simulation for some number of cycles then finish
reg [9:0] sim_count;
always @ (posedge clk_12mhz)
begin
    if (reset) begin
        sim_count <= 0;
        valid_in <= 0;
    end else begin
        if (en) begin
            sim_count <= sim_count + 1;
            if (sim_count == 1) begin
                valid_in <= 1;
            end else begin
                valid_in <= 0;
            end
            if (sim_count == 390) begin
                $finish;
            end
        end
    end
end


endmodule

