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
* 2. Receive 'n' characters for md5 processing.
* 3. Process 'n' characters for md5 processing.
*
* The difference between 2 and 3, is that three
* makes sure that the 'n' characters have made
* it all the way through the md5 pipeline before
* returning.  While type 2 just makes sure that
* 'n' characters have gotten into the the pipleline.  
* Type three is good for processing the last
* data chunk.
*
* Target Board: iCE40HX-8K Breakout Board.
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

    input wire [7:0] rxd_data,
    input wire rxd_data_ready,

    output reg [7:0] txd_data,
    output reg txd_start,
    output reg [7:0] leds
);


/*
*****************************
* Parameters
*****************************
*/

// States
localparam IDLE         = 0;
localparam SET_HASH     = 1;
localparam RECV_CHARS   = 2;
localparam PROC_CHARS   = 3;
localparam ACK          = 4;

// Character constants
localparam SET_CMD      = 8'h01;
localparam RECV_CMD     = 8'h02;
localparam PROC_CMD     = 8'h03;

// Character constants
localparam NACK_CHAR    = 8'h00;
localparam ACK_CHAR     = 8'h01;

/*
*****************************
* Main
*****************************
*/

reg [2:0] cmd_state;
reg [15:0] char_count;
always (@posedge clk_96mhz)
begin
    if (reset) begin
        cmd_state   <= IDLE;
        leds        <=0;
        char_count  <= 0;
        txd_data <= NACK_CHAR;
        txd_start <= 0;
    end else begin
        case (cmd_state)
            IDLE : begin
                leds <= 1;
                char_count <= 0;
                txd_data <= NACK_CHAR;
                txd_start <= 0;
                // Waiting for a command byte
                if (rxd_data_ready) begin
                    if (rxd_data == SET_CMD) begin
                        cmd_state <= SET_HASH;
                    end else if (rxd_data == RECV_CMD) begin
                        cmd_state <= RECV_CHARS;
                    end else if (rxd_data == PROC_CMD) begin
                        cmd_state <= PROC_CHARS;
                    end
                end
            end
            SET_HASH : begin
                leds <= 2;
                if (rxd_data_ready) begin
                    target_hash[127:0] <= {target_hash[119:0],rxd_data};
                    char_count <= char_count + 1;
                    if (char_count == 15) begin
                        cmd_state <= ACK;
                    end
                end
            end
            RECV_CHARS : begin
                leds <= 3;
            end
            PROC_CHARS : begin
                leds <= 4;
            end
            ACK : begin
                leds <= 5;
                if (!txd_busy) begin
                    txd_data <= ACK_CHAR;
                    txd_start <= 1;
                    cmd_state <= IDLE;
                end
            end
            default : begin
                cmd_state <= IDLE;
            end
        endcase
    end
end





endmodule

