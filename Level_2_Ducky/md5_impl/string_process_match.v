/*
*****************************
* MODULE : string_process_match
*
* This module buffers characters into 19-char
* strings that will be sent the md5 hasher module.
* It also checks to see if one of the hashes
* match the target hash.
*
* Target Board: iCE40HX-8K Breakout Board.
* Status: In development.
*
* Author : Brandon Bloodget
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module string_process_match
(
    input wire clk_96mhz,
    input wire reset,

    // cmd_parser
    input wire proc_start,
    input wire [15:0] proc_num_bytes,
    input wire [7:0] proc_data,
    input wire proc_data_valid,
    input wire proc_match_char_next,
    input wire [127:0] proc_target_hash,
    output reg proc_done,
    output reg proc_match,
    output reg [15:0] proc_byte_pos,
    output reg [7:0] proc_match_char,

    // MD5 core
    input wire [511:0] m_in,
    input wire valid_in
    input wire [31:0] a_in, b_in, c_in, d_in,
    output wire [511:0] m_out,
    output wire valid_out
);

/*
*****************************
* Main
*****************************
*/

// Latch the number of bytes to send through md5.
reg [15:0] num_bytes;
always @(posedge clk)
begin
    if (reset) begin
        num_bytes <= 0;
    end else begin
        if (proc_start) begin
            num_bytes <= proc_num_bytes;
        end
    end
end

// Create the message.
always @(posedge clk)
begin
    if (reset) begin
    end else begin
    end
end



endmodule

