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
    input wire clk,
    input wire reset,

    // cmd_parser
    input wire proc_start,
    input wire [15:0] proc_num_bytes,
    input wire [7:0] proc_data,
    input wire proc_data_valid,
    input wire proc_match_char_next,
    input wire [127:0] proc_target_hash,
    output wire proc_done,
    output wire proc_match,
    output wire [15:0] proc_byte_pos,
    output wire [7:0] proc_match_char,

    // MD5 core
    input wire [31:0] a_ret, b_ret, c_ret, d_ret,
    input wire [151:0] md5_msg_ret,
    input wire md5_msg_ret_valid,
    output reg  [151:0] md5_msg,
    output reg md5_msg_valid

);
/*
*****************************
* Assignments
*****************************
*/

wire [31:0] a_target, b_target, c_target, d_target;

assign a_target = proc_target_hash[127:96];
assign b_target = proc_target_hash[95:64];
assign c_target = proc_target_hash[63:32];
assign d_target = proc_target_hash[31:0];

assign proc_done = match_check_done;
assign proc_match = match;
assign proc_byte_pos = num_bytes;
assign proc_match_char = match_msg[151:144];


/*
*****************************
* Main
*****************************
*/


// Create and send the message.
always @(posedge clk)
begin
    if (reset) begin
        md5_msg <= 0;
        md5_msg_valid <= 0;
    end else begin
        if (proc_data_valid) begin
            md5_msg[151:0] <= {md5_msg[143:0],proc_data[7:0]};
            md5_msg_valid <= 1;
        end else begin
            md5_msg_valid <= 0;
        end
    end
end

// Check md5core return values for a match to target.
// Count the number of returned hashes.
reg [15:0] byte_count;
reg [15:0] num_bytes;
reg match;
reg [15:0] match_byte_count;
reg [151:0] match_msg;
reg match_check_done;
always @(posedge clk)
begin
    if (reset) begin
        num_bytes <= 0;
        byte_count <= 0;
        match <= 0;
        match_byte_count <= 0;
        match_msg <= 0;
        match_check_done <= 0;
    end else begin
        // Check return hashes for match with target.
        if (md5_msg_ret_valid) begin
            byte_count <= byte_count + 1;
            if (  (a_ret == a_target) &&
                  (b_ret == b_target) &&
                  (c_ret == c_target) &&
                  (d_ret == d_target) ) begin
                match <= 1;
                match_byte_count <= byte_count;
                match_msg <= md5_msg_ret;
            end
        end
        // Shift the matched string out
        if (proc_match_char_next) begin
            match_msg[151:0] <= {match_msg[143:0], 8'h0};
        end
        // Check if we have processed the specified
        // number of bytes.
        if (byte_count == num_bytes) begin
            match_check_done <= 1;
        end
        // Starting a new batch of strings.
        if (proc_start) begin
            num_bytes <= proc_num_bytes;
            byte_count <= 0;
            match <= 0;
            match_byte_count <= 0;
            match_msg <= 0;
            match_check_done <= 0;
        end
    end
end


endmodule

