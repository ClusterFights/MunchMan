/*
*****************************
* MODULE : sim_top_tb
*
* Testbench for the cmd_parser,
* string_process_match and md5core modules
* all working together.
*
* Author : Brandon Bloodget
* Create Date : 10/25/2018
* Status : Developoment
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

`timescale 1 ns / 1 ps

`define TESTBENCH
`define NULL    0

module sim_top_tb;

/*
*****************************
* Inputs (registers)
*****************************
*/

reg clk;
reg reset;
reg rxd;

/*
*****************************
* Outputs (wires)
*****************************
*/

wire txd;
wire match_led;
wire [3:0] led;

/*
*****************************
* Internal (wires)
*****************************
*/

integer file, r;  // file handler

reg finished;

/*
*****************************
* Parameters
*****************************
*/

parameter CLK_FREQUENCY = 100_000_000;
parameter BAUD = 12_000_000;
parameter NUM_LEDS = 4;
parameter FILE_SIZE_IN_BYTES = 163_185;

/*
******************************************
* Testbench memories
******************************************
*/

// tv_mem holds bytes from the
// sample text file alice30.txt
reg [7:0] tv_mem [0:FILE_SIZE_IN_BYTES-1];

/*
*****************************
* Instantiations (DUT)
*****************************
*/

top_md5 #
(
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .BAUD(BAUD),
    .NUM_LEDS(NUM_LEDS)
) top_md5_inst
(
    .clk(clk),
    .reset(reset),
    .rxd(rxd),

    .txd(txd),
    .match_led(match_led),
    .led(led)
);

/*
*****************************
* Main
*****************************
*/

// Main testbench
initial begin
    // initialize memories
    file = $fopen("alice30.txt", "rb");
    if (file == `NULL)
    begin
        $display("data_file handle was NULL");
        $finish;
    end
    r = $fread(tv_mem, file);
    $display("r: ",r);
    $display("feof: ",$feof(file));
    $fclose(file);

    // initialize registers
    clk             = 0;
    reset           = 0;
    rxd             = 0;

    // Wait 100 ns for global reset to finish
    #100;
    // Add stimulus here
    @(posedge clk);
    reset   = 1;
    @(posedge clk);
    @(posedge clk);
    reset   = 0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge finished);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    $finish;
end


// Generate a 100mhz clk
always begin
    #5 clk <= ~clk;
end

reg [15:0] count;
always @ (posedge clk)
begin
    if (reset) begin
        count <= 0;
        finished <= 0;
    end else begin
        count <= count + 1;
        $display("%d %c",count, tv_mem[count]);
        if (count == 50) begin
            finished <= 1;
        end
    end
end

endmodule

