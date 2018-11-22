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

`timescale 1 ns / 1 ns

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


parameter CMD_SET_HASH_OP       = 8'h01;
parameter CMD_SEND_TEXT_OP      = 8'h02;
parameter CMD_READ_MATCH_OP     = 8'h03;
parameter CMD_TEST_OP           = 8'h04;

parameter BUFFER_SIZE           = 100;

/*
******************************************
* Testbench memories
******************************************
*/

// tv_mem holds bytes from the
// sample text file alice30.txt
reg [7:0] tv_mem [0:FILE_SIZE_IN_BYTES-1];

// the target hash
reg [127:0] target_hash = 128'ha2004f37_730b9445_670a738f_a0fc9ee5;

// Buffer for the text to be sent to FPGA.
reg [(BUFFER_SIZE*8)-1:0] text_str;

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
    text_str        = 0;

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
    // XXX cmd_test;
    cmd_set_hash;
    @(posedge clk_100mhz);
    @(posedge clk_100mhz);
    cmd_send_text(BUFFER_SIZE);
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

// Wait for transmitter to not be busy
task wait_for_transmit_ready;
begin
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
end
endtask

// Task to send a character
task send_char;
    input [7:0] char;
begin
    wait_for_transmit_ready;
    @ (posedge clk_100mhz);
    txd_start = 1;
    txd_data = char;
    @ (posedge clk_100mhz);
    txd_start = 0;
end
endtask

// Read the ack
task read_ack;
begin
    $display("%t: begin read_ack",$time);
    i=0;
    done = 0;
    while(!done)
    begin
        if (data_out_ready==1)
        begin
            $display("%t: ACK value=%d",$time,data_out);
            done = 1;
        end
        @ (posedge clk_100mhz);
        i = i + 1;
        if (i == 1000)
        begin
            $display("%t: ERROR no ACK",$time);
            done = 1;
        end
    end
end
endtask


// Task to send test cmd.
task cmd_test;
begin
    $display("\n%t: BEGIN cmd_test",$time);
    // Send the command
    send_char(CMD_TEST_OP);

    // Read Back the test data
    done = 0;
    i = 0;
    while(!done)
    begin
        @ (posedge clk_100mhz);
        if (data_out_ready==1)
        begin
            $display("%t: %d val=%d",$time,i,data_out);
            if (data_out==1)
                done = 1;
        end
        i = i + 1;
    end
    $display("\n%t: END cmd_test",$time);

end
endtask

// Task to send target hash
task cmd_set_hash;
begin
    $display("\n%t: BEGIN cmd_set_hash",$time);

    // Send the command
    send_char(CMD_SET_HASH_OP);

    // Send the 16 target hash bytes
    for (i=15; i>=0; i=i-1)
    begin
        send_char(target_hash[8*i +: 8]);
        $display("%t: %d hash_byte:%2x",$time,i,txd_data);
    end

    // Read the ack
    read_ack;

    // Print value.
    $display("%t cmd_state=%x",$time,top_md5_inst.cmd_parser_inst.cmd_state);
    $display("%t target_hash=%x",$time,top_md5_inst.cmd_parser_inst.target_hash);
    $display("%t: END cmd_set_hash",$time);
end
endtask


// Task to send a block of text
task cmd_send_text;
    input [15:0] text_str_len;
begin
    $display("\n%t: BEGIN cmd_send_text",$time);

    // Send the command
    send_char(CMD_SEND_TEXT_OP);

    // Send the number of bytes to be sent
    // Send MSB first
    send_char(text_str_len[15:8]);
    $display("%t: MSB len=%x",$time,txd_data);
    // Send LSB second
    send_char(text_str_len[7:0]);
    $display("%t: LSB len=%x",$time,txd_data);

    // Send the characters
    for (i=0; i <text_str_len; i++)
    begin
        send_char(text_str[8*i +: 8]);
        $display("%t: %d char=%x",$time,i,txd_data);
    end

    // Read the ack
    read_ack;

    $display("%t: END cmd_send_text",$time);
end
endtask





// Generate a 100mhz clk
always begin
    #5 clk_100mhz <= ~clk_100mhz;
end

endmodule

