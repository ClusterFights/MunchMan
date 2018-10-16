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
    // m is a 16th of the full message
    // higher level code pass in the
    // correct part for this "index"
    input wire [31:0] m,

    output wire [31:0] a_out, b_out, c_out, d_out
);

/*
*****************************
* Signals
*****************************
*/

// XXX wire [31:0] f_out = f(index, b, c, d);
wire [31:0] f_out; 

assign f_out = f(index,b,c,d); //(b & c) | ((~b) & d);

/*
*****************************
* Assignments
*****************************
*/

assign a_out = a6;
assign b_out = b6;
assign c_out = c6;
assign d_out = d6;

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

function[31:0] leftrotate;
input [31:0] x, c;
begin
    leftrotate= (x<<c) | (x >> (32-c));
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
        a1 <=- 0;
        b1 <=- 0;
        c1 <=- 0;
        d1 <=- 0;
    end else begin
        if (en) begin
            a1 <= a + f_out;
            b1 <= b;
            c1 <= c;
            d1 <= d;
        end
    end
end

// Stage 2
reg [31:0] a2, b2, c2, d2;
always @ (posedge clk)
begin
    if (reset) begin
        a2 <=- 0;
        b2 <=- 0;
        c2 <=- 0;
        d2 <=- 0;
    end else begin
        if (en) begin
            a2 <= a1 + m;
            b2 <= b1;
            c2 <= c1;
            d2 <= d1;

        end
    end
end

// Stage 3
reg [31:0] a3, b3, c3, d3;
always @ (posedge clk)
begin
    if (reset) begin
        a3 <=- 0;
        b3 <=- 0;
        c3 <=- 0;
        d3 <=- 0;
    end else begin
        if (en) begin
            a3 <= a2 + k;
            b3 <= b2;
            c3 <= c2;
            d3 <= d2;

        end
    end
end

// Stage 4
reg [31:0] a4, b4, c4, d4;
always @ (posedge clk)
begin
    if (reset) begin
        a4 <=- 0;
        b4 <=- 0;
        c4 <=- 0;
        d4 <=- 0;
    end else begin
        if (en) begin
            a4 <= leftrotate(a3,s);
            b4 <= b3;
            c4 <= c3;
            d4 <= d3;

        end
    end
end

// Stage 5
reg [31:0] a5, b5, c5, d5;
always @ (posedge clk)
begin
    if (reset) begin
        a5 <=- 0;
        b5 <=- 0;
        c5 <=- 0;
        d5 <=- 0;
    end else begin
        if (en) begin
            a5 <= a4 + b4;
            b5 <= b4;
            c5 <= c4;
            d5 <= d4;

        end
    end
end

// Stage 6
reg [31:0] a6, b6, c6, d6;
always @ (posedge clk)
begin
    if (reset) begin
        a6 <=- 0;
        b6 <=- 0;
        c6 <=- 0;
        d6 <=- 0;
    end else begin
        if (en) begin
            a6 <= d5;
            b6 <= a5;
            c6 <= b5;
            d6 <= c5;

        end
    end
end


endmodule

