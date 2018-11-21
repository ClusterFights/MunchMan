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

// top_md5
reg clk_100mhz;
reg reset;

// async_transmitter
reg txd_start;
reg [7:0] txd_data;


/*
*****************************
* Outputs (wires)
*****************************
*/

// top_md5
wire serial_out;
wire match_led;
wire [3:0] led;

// async_transmitter
wire txd_busy;
wire serial_in;

// async_receiver
wire data_out_ready;
wire [7:0] data_out;
wire data_out_idle;
wire data_out_endofpacket;

/*
*****************************
* Internal (wires)
*****************************
*/

integer file, r;    // file handler
integer i;          // loop counter

reg finished;
reg done;

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
    .clk(clk_100mhz),
    .reset(reset),
    .rxd(serial_in),

    .txd(serial_out),
    .match_led(match_led),
    .led(led)
);

async_transmitter # (
    .ClkFrequency(CLK_FREQUENCY),
    .Baud(BAUD)
) async_transmitter_inst (
    .clk(clk_100mhz),
    .TxD_start(txd_start),
    .TxD_data(txd_data),
    .TxD(serial_in),
    .TxD_busy(txd_busy)
);

async_receiver # (
    .ClkFrequency(CLK_FREQUENCY),
    .Baud(BAUD)
) async_receiver_inst (
    .clk(clk_100mhz),
    .RxD(serial_out),
    .RxD_data_ready(data_out_ready),
    .RxD_data(data_out),
    .RxD_idle(data_out_idle),
    .RxD_endofpacket(data_out_endofpacket)
);

/*
*****************************
* Main
*****************************
*/

// Main testbench
initial begin
    // For viewer
    $dumpfile("sim_top.vcd");
    $dumpvars;

    // initialize memories
    file = $fopen("alice30.txt", "rb");
    if (file == `NULL)
    begin
        $display("data_file handle was NULL");
    while (txd_busy == 1)
    begin
        @ (posedge clk_100mhz);
    end
        $finish;
    end
    r = $fread(tv_mem, file);
    $display("r: ",r);
    $display("feof: ",$feof(file));
    $fclose(file);

    // initialize registers
    clk_100mhz      = 0;
    reset           = 0;
    txd_start       = 0;
    txd_data        = 0;

    // Wait 100 ns for global reset to finish
    #100;
    // Add stimulus here
    @(posedge clk_100mhz);
    reset   = 1;
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    reset   = 0;
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    cmd_test;
//    @(posedge finished);
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    $finish;
end


// Test reading from tv_mem
/*
reg [15:0] count;
always @ (posedge clk_100mhz)
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
*/

// Task to send test cmd 0x04.
task cmd_test;
begin
    // Wait for transmitter to not be busy
    @ (posedge clk_100mhz);
    done = 0;
    while(!done)
    begin
        @ (posedge clk_100mhz);
        if (txd_busy == 0)
        begin
            done = 1;
        end
    end

    // Send the test_cmd 0x04
    @ (posedge clk_100mhz);
    txd_start = 1;
    txd_data = 8'h04;

    @ (posedge clk_100mhz);
    txd_start = 0;
    txd_data = 8'h00;

    // Read Back the test data
    done = 0;
    i = 0;
    while(!done)
    begin
        @ (posedge clk_100mhz);
        if (data_out_ready==1)
        begin
            $display("%d val=%d",i,data_out);
            if (data_out==1)
                done = 1;
        end
        i = i + 1;
    end

end
endtask


// Generate a 100mhz clk
always begin
    #5 clk_100mhz <= ~clk_100mhz;
end

endmodule

