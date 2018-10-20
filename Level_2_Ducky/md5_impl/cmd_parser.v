/*
*****************************
* MODULE : cmd_parser
*
* This module receives a stream of
* characters and parses the incoming commands.
* Implements a state-machine that 
* executes the commands.  There are three
* commands:
*
* 1. Set target hash.
* 2. Process 'n' characters for md5 processing.
* 3. Return match position and string.
*
* Multi-byte parameters and return values are
* send MSB first (big endian/network order).
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

module cmd_parser 
(
    input wire clk_96mhz,
    input wire reset,

    // uart_rx (receive)
    input wire [7:0] rxd_data,
    input wire rxd_data_ready,

    // uart_tx (transmit)
    input wire txd_busy,
    output reg txd_start,
    output reg [7:0] txd_data,

    // char_buff (process)
    input wire proc_done,
    input wire proc_match,
    input wire [15:0] proc_byte_pos,
    input wire [7:0] proc_match_char,
    output reg proc_start,
    output reg [15:0] proc_num_bytes,
    output reg [7:0] proc_data,
    output reg proc_data_valid,
    output reg proc_match_char_next,

    // feedback/debug
    output wire [7:0] leds
);

/*
*****************************
* Assignments
*****************************
*/

assign leds[7:0] = cmd_state[7:0];

/*
*****************************
* Parameters
*****************************
*/

// States
localparam IDLE         = 0;
localparam SET_HASH     = 1;
localparam PROC_CHARS1  = 2;
localparam PROC_CHARS2  = 3;
localparam PROC_CHARS3  = 4;
localparam RET_CHARS1   = 5;
localparam RET_CHARS2   = 5;
localparam ACK          = 6;
localparam NACK         = 7;

// Character constants
localparam SET_CMD      = 8'h01;
localparam PROC_CMD     = 8'h02;
localparam RET_CMD      = 8'h03;

// Character constants
localparam NACK_CHAR    = 8'h00;
localparam ACK_CHAR     = 8'h01;

/*
*****************************
* Main
*****************************
*/

reg [7:0] cmd_state;
reg [15:0] char_count;
reg [127:0] target_hash;
reg [15:0] num_bytes;
always @ (posedge clk_96mhz)
begin
    if (reset) begin
        cmd_state   <= IDLE;
            proc_data <= 0;
            proc_data_valid <= 0;
        char_count  <= 0;
        txd_data <= NACK_CHAR;
        txd_start <= 0;
        target_hash <= 0;
        proc_data <= 0;
        proc_data_valid <= 0;
        proc_start <= 0;
        proc_num_bytes <= 0;
        proc_match_char_next <= 0;
    end else begin
        case (cmd_state)
            IDLE : begin
                char_count <= 0;
                txd_data <= NACK_CHAR;
                txd_start <= 0;
                proc_data <= 0;
                proc_data_valid <= 0;
                proc_start <= 0;
                proc_num_bytes <= 0;
                proc_match_char_next <= 0;
                // Waiting for a command byte
                if (rxd_data_ready) begin
                    if (rxd_data == SET_CMD) begin
                        cmd_state <= SET_HASH;
                    end else if (rxd_data == PROC_CMD) begin
                        cmd_state <= PROC_CHARS1;
                    end else if (rxd_data == RET_CMD) begin
                        cmd_state <= RET_CHARS1;
                    end
                end
            end
            SET_HASH : begin
                if (rxd_data_ready) begin
                    target_hash[127:0] <= {target_hash[119:0],rxd_data};
                    char_count <= char_count + 1;
                    if (char_count == 15) begin
                        cmd_state <= ACK;
                    end
                end
            end
            PROC_CHARS1 : begin
                // Read the number of bytes
                if (rxd_data_ready) begin
                    num_bytes[15:0] <= {num_bytes[7:0],rxd_data};
                    char_count <= char_count + 1;
                    if (char_count == 1) begin
                        char_count <= 0;
                        proc_num_bytes <= num_bytes;
                        proc_start <= 1;
                        cmd_state <= PROC_CHARS2;
                    end
                end
            end
            PROC_CHARS2 : begin
                proc_start <= 0;
                // Read in the characters to process.
                if (rxd_data_ready) begin
                    proc_data <= rxd_data;
                    proc_data_valid <= 1;
                    char_count <= char_count + 1;
                    if (char_count == (num_bytes-1)) begin
                        proc_data_valid <= 0;
                        cmd_state <= PROC_CHARS3;
                    end
                end else begin
                    proc_data_valid <= 0;
                end
            end
            PROC_CHARS3 : begin
                // Wait for hash to complete.
                if (proc_done) begin
                    if (proc_match) begin
                        cmd_state <= ACK;
                    end else begin
                        cmd_state <= NACK;
                    end
                end
            end
            RET_CHARS1 : begin
                // Return match byte position
                if (!txd_busy) begin
                    txd_data <= (char_count==0) ? proc_byte_pos[15:8] :
                        proc_byte_pos[7:0];
                    txd_start <= 1;
                    char_count <= char_count + 1;
                    if (char_count == 1) begin
                        char_count <= 0;
                        cmd_state <= RET_CHARS2;
                    end
                end else begin
                    txd_start <= 0;
                end
            end
            RET_CHARS2 : begin
                // Return the matched string
                if (!txd_busy) begin
                    txd_data <= proc_match_char;
                    proc_match_char_next <= 1;
                    txd_start <= 1;
                    txd_data <= ACK_CHAR;
                    txd_start <= 1;
                    char_count <= char_count + 1;
                    if (char_count == 18) begin
                        cmd_state <= IDLE;
                    end
                end else begin
                    proc_match_char_next <= 0;
                    txd_start <= 0;
                end
            end
            ACK : begin
                if (!txd_busy) begin
                    txd_data <= ACK_CHAR;
                    txd_start <= 1;
                    cmd_state <= IDLE;
                end else begin
                    txd_start <= 0;
                end
            end
            NACK : begin
                if (!txd_busy) begin
                    txd_data <= NACK_CHAR;
                    txd_start <= 1;
                    cmd_state <= IDLE;
                end else begin
                    txd_start <= 0;
                end
            end
            default : begin
                cmd_state <= IDLE;
            end
        endcase
    end
end

endmodule


