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

module sim_top_tb;

// Inputs (registers)
reg clk;
reg reset;
reg [7:0] rxd_data;
reg rxd_data_ready;
reg txd_busy;


// Outputs (wires)
wire txd_start;
wire [7:0] txd_data;
wire [7:0] led;


// Define the tests.

// test1 : set the target hash.
// hash is for "The quick brown fox"
reg [135:0] test1 = 136'h01_a2004f37_730b9445_670a738f_a0fc9ee5;

// test2 : Send the text string.
// string : "Hello. The quick brown fox jumps over the lazy dog."
// string length is 51 dec or 0x33.
// total length in bytes is 54 dec.
reg [431:0] test2 = 432'h02_0033_48656c6c_6f2e2054_68652071_7569636b_2062726f_776e2066_6f78206a_756d7073_206f7665_72207468_65206c61_7a792064_6f672e;

/*
*****************************
* Instantiations (DUT)
*****************************
*/

sim_top sim_top_inst
(
    .clk(clk),
    .reset(reset),

    // uart_rx (receive)
    .rxd_data(rxd_data),   // [7:0] 
    .rxd_data_ready(rxd_data_ready),

    // uart_tx (transmit)
    .txd_busy(txd_busy),

    .txd_start(txd_start),
    .txd_data(txd_data),   // [7:0] 

    .led(led)    // [7:0] 
);

/*
*****************************
* Main
*****************************
*/
initial begin
    $dumpfile("sim_top.vcd");
    $dumpvars;
    clk = 0;
    reset = 0;
    rxd_data = 0;
    rxd_data_ready = 0;
    txd_busy = 0;

    // Wait 100ns
    #100;
    // Add stimulus here
    @(posedge clk);
    reset = 1;
    @(posedge clk);
    @(posedge clk);
    reset = 0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
end


// Internal signals
reg [7:0] tb_state;
reg [10:0] tb_char_count;
reg [15:0] ret_byte_pos;

// States
localparam IDLE             = 0;
localparam TEST1            = 1;
localparam TEST1_RET        = 2;
localparam EXTRA_CLOCKS1    = 3;
localparam TEST2            = 4;
localparam TEST2_RET        = 5;
localparam EXTRA_CLOCKS2    = 6;
localparam TEST3            = 7;
localparam TEST3_RET1       = 8;
localparam TEST3_RET2       = 9;
localparam EXTRA_CLOCKS3    = 10;
localparam FINISHED         = 11;

always @ (posedge clk)
begin
    if (reset) begin
        tb_state <= IDLE;
        tb_char_count <= 0;
        ret_byte_pos <= 0;
    end else begin
        case (tb_state)
            IDLE : begin
                tb_char_count <= 17;
                tb_state <= TEST1;
            end
            TEST1 : begin
                rxd_data_ready <= 1;
                rxd_data <= test1[135:128];
                test1[135:0] <= {test1[127:0],8'h0};
                tb_char_count <= tb_char_count - 1;
                if (tb_char_count == 0) begin
                    rxd_data_ready <= 0;
                    rxd_data <= 0;
                    tb_state <= TEST1_RET;
                end
            end
            TEST1_RET : begin
                if (txd_start) begin
                    $display("TEST1 ACK: %d",txd_data);
                    tb_char_count <= 4;
                    tb_state <= EXTRA_CLOCKS1;
                end
            end
            EXTRA_CLOCKS1 : begin
                tb_char_count <= tb_char_count - 1;
                if (tb_char_count == 0) begin
                    tb_char_count <= 54;
                    tb_state <= TEST2;
                end
            end
            TEST2 : begin
                rxd_data_ready <= 1;
                rxd_data <= test2[431:424];
                test2[431:0] <= {test2[423:0],8'h0};
                tb_char_count <= tb_char_count - 1;
                if (tb_char_count == 0) begin
                    rxd_data_ready <= 0;
                    rxd_data <= 0;
                    tb_state <= TEST2_RET;
                end
            end
            TEST2_RET : begin
                if (txd_start) begin
                    $display("TEST2 ACK: %d",txd_data);
                    tb_char_count <= 4;
                    tb_state <= EXTRA_CLOCKS2;
                end
            end
            EXTRA_CLOCKS2 : begin
                tb_char_count <= tb_char_count - 1;
                if (tb_char_count == 0) begin
                    tb_state <= TEST3;
                end
            end
            TEST3 : begin
                // Send cmd 0x03. To read match data
                rxd_data_ready <= 1;
                rxd_data <= 8'h03;
                tb_char_count <= 2;
                tb_state <= TEST3_RET1;
            end
            TEST3_RET1 : begin
                rxd_data_ready <= 0;
                if (txd_start) begin
                    tb_char_count <= tb_char_count - 1;
                    ret_byte_pos[15:0] <= {ret_byte_pos[7:0],txd_data[7:0]};
                end
                if (tb_char_count == 0) begin
                    $display("byte_pos: %d",ret_byte_pos);
                    tb_char_count <= 19;
                    tb_state <= TEST3_RET2;
                end
            end
            TEST3_RET2 : begin
                if (txd_start) begin
                    tb_char_count <= tb_char_count - 1;
                    $display("%x %s",txd_data, txd_data);
                end
                if (tb_char_count == 0) begin
                    tb_char_count <= 4;
                    tb_state <= EXTRA_CLOCKS3;
                end
            end
            EXTRA_CLOCKS3 : begin
                tb_char_count <= tb_char_count - 1;
                if (tb_char_count == 0) begin
                    tb_state <= FINISHED;
                end
            end
            FINISHED : begin
                $finish;
            end
            default : begin
                tb_state <= IDLE;
            end
        endcase
    end
end


// Generate a ~12mhz clk
always begin
    #41 clk <= ~clk;
end


endmodule


