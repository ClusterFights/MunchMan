/*
*****************************
* MODULE : hash_op
*
* This module implements one MD5 operation.
* MD5 consists of 64 of these operations,
* grouped in four rounds of 16 operations.
* 
* For more info about the algorithm see:
* https://en.wikipedia.org/wiki/MD5
*
* Target Board: iCE40HX-8K Breakout Board.
*
* Author : Brandon Bloodget
* Create Date: 10/14/2018
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module hash_op #
(
    parameter integer index = 0,
    parameter integer s = 0,
    parameter integer k = 0
)
(
    input wire clk,
    input wire reset,
    input wire en,

    input wire [31:0] a, b, c, d,
    input wire [511:0] m_in,

    output reg [31:0] a_out, b_out, c_out, d_out,
    output reg [511:0] m_out
);

/*
*****************************
* Signals
*****************************
*/

// Break the message (m_in) into sixteen
// 32-bit words m[j] 0 <= j <= 15
wire [15:0] m [31:0];

/*
*****************************
* Assignments
*****************************
*/

// Generate the assignments to break
// message (m_in) into sixteen 32-bit words.
genvar gi;
generate
for (gi=0; gi<16; gi=gi+1) begin: mesg_i
    assign m[gi] = m_in[32*gi +: 32];
end
endgenerate


/*
*****************************
* Functions
*****************************
*/

function[31:0] f;
input [31:0] i, b, c, d;
begin
    if (i<16)
        f = (b & c) | ((~b) & d);
    else if (i<32)
        f = (d & b) | ((~d) & c);
    else if (i<48)
        f =  b ^ c ^ d;
    else
        f = c ^ (b | (~d));
end
endfunction

function[31:0] g;
input [31:0] i;
begin
    if (i<16)
        g = i;
    else if (i<32)
        g = (5*i + 1) % 16;
    else if (i<48)
        g = (3*i + 5) % 16;
    else
        g = (7*i) % 16;
end
endfunction

/*
*****************************
* Main
*****************************
*/

// Stage 1
reg [31:0] a1, b1, c1, d1;
always @ (posedge clk)
begin
    if (reset) begin
    end else begin
        if (en) begin
            a1 <= a + f(index, b, c, d);
            b1 <= b;
            c1 <= c;
            d1 <= d;
        end
    end
end

// Stage 2
always @ (posedge clk)
begin
    if (reset) begin
    end else begin
        if (en) begin
            a_out <= a1 + m[index];
            b_out <= b1;
            c_out <= c1;
            d_out <= d1;

            m_out <= m_in;
        end
    end
end

endmodule

