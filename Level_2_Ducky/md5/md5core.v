/*
*****************************
* MODULE : md5core
*
* This module instantiates 64 hash_op
* modules to implement the core of the
* md5 hash algorithm.
*
* Target Board: iCE40HX-8K Breakout Board.
*
* Author : Brandon Bloodget
* Create Date: 10/16/2018
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

module md5core
(
    input wire clk,
    input wire reset,
    input wire en,

    input wire [511:0] mesg,

    output reg [31:0] a_out, b_out, c_out, d_out
);

/*
*****************************
* Parameters
*****************************
*/

localparam [32*64-1:0] k = {
    32'hd76aa478, 32'he8c7b756, 32'h242070db, 32'hc1bdceee,
    32'hf57c0faf, 32'h4787c62a, 32'ha8304613, 32'hfd469501,
    32'h698098d8, 32'h8b44f7af, 32'hffff5bb1, 32'h895cd7be,
    32'h6b901122, 32'hfd987193, 32'ha679438e, 32'h49b40821,
    32'hf61e2562, 32'hc040b340, 32'h265e5a51, 32'he9b6c7aa,
    32'hd62f105d, 32'h02441453, 32'hd8a1e681, 32'he7d3fbc8,
    32'h21e1cde6, 32'hc33707d6, 32'hf4d50d87, 32'h455a14ed,
    32'ha9e3e905, 32'hfcefa3f8, 32'h676f02d9, 32'h8d2a4c8a,
    32'hfffa3942, 32'h8771f681, 32'h6d9d6122, 32'hfde5380c,
    32'ha4beea44, 32'h4bdecfa9, 32'hf6bb4b60, 32'hbebfbc70,
    32'h289b7ec6, 32'heaa127fa, 32'hd4ef3085, 32'h04881d05,
    32'hd9d4d039, 32'he6db99e5, 32'h1fa27cf8, 32'hc4ac5665,
    32'hf4292244, 32'h432aff97, 32'hab9423a7, 32'hfc93a039,
    32'h655b59c3, 32'h8f0ccc92, 32'hffeff47d, 32'h85845dd1,
    32'h6fa87e4f, 32'hfe2ce6e0, 32'ha3014314, 32'h4e0811a1,
    32'hf7537e82, 32'hbd3af235, 32'h2ad7d2bb, 32'heb86d391
};

localparam [64*5-1:0] s = {
    5'd7, 5'd12, 5'd17, 5'd22,  5'd7, 5'd12, 5'd17, 5'd22,
    5'd7, 5'd12, 5'd17, 5'd22,  5'd7, 5'd12, 5'd17, 5'd22,
    5'd5,  5'd9, 5'd14, 5'd20,  5'd5, 5'd9,  5'd14, 5'd20,
    5'd5, 5'd9,  5'd14, 5'd20,  5'd5, 5'd9,  5'd14, 5'd20,
    5'd4, 5'd11, 5'd16, 5'd23,  5'd4, 5'd11, 5'd16, 5'd23,
    5'd4, 5'd11, 5'd16, 5'd23,  5'd4, 5'd11, 5'd16, 5'd23,
    5'd6, 5'd10, 5'd15, 5'd21,  5'd6, 5'd10, 5'd15, 5'd21,
    5'd6, 5'd10, 5'd15, 5'd21,  5'd6, 5'd10, 5'd15, 5'd21
};

localparam[31:0] a0 = 32'h67452301;
localparam[31:0] b0 = 32'hefcdab89;
localparam[31:0] c0 = 32'h98badcfe;
localparam[31:0] d0 = 32'h10325476;

/*
*****************************
* Functions
*****************************
*/

function [31:0] swap_endian_32b;
input [32:0] in;
begin
    swap_endian_32b = {in[0+:8], in[8+:8], in[16+:8], in[24+:8]};
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
* Signals
*****************************
*/

// Break the message (m_in) into sixteen
// 32-bit words m[j] 0 <= j <= 15
wire [31:0] m [15:0];

// Wires between the 64 hash_op modules
wire[31:0] hop_a [0:64];
wire[31:0] hop_b [0:64];
wire[31:0] hop_c [0:64];
wire[31:0] hop_d [0:64];

/*
*****************************
* Assignments
*****************************
*/

// Generate the assignments to break
// message (mesg) into sixteen 32-bit words.
genvar gi;
generate
    for (gi=0; gi<16; gi=gi+1) begin: sig_gi
        assign m[gi] = mesg[32*(15-gi) +: 32];
    end
endgenerate


/*
*****************************
* Instantiations
*****************************
*/

// Stage/index 0.
hash_op #
(
    .index(0),
    .s(s[5*(63-0) +: 5]),
    .k(k[32*(63-0) +: 32])
) hash_op_inst
(
    .clk(clk),
    .reset(reset),
    .en(en),

    // Initial values of a,b,c,d
    .a(a0),
    .b(b0),
    .c(c0),
    .d(d0),
    // m is a 16th of the full message
    .m(swap_endian_32b(m[0])),

    .a_out(hop_a[1]),
    .b_out(hop_b[1]),
    .c_out(hop_c[1]),
    .d_out(hop_d[1])
);

// Stage/index 1..63.
generate
    for(gi=1; gi<64; gi=gi+1) begin: hash_op_gi
        hash_op #
        (
            .index(gi),
            .s(s[5*(63-gi) +: 5]),
            .k(k[32*(63-gi) +: 32])
        ) hash_op_inst
        (
            .clk(clk),
            .reset(reset),
            .en(en),

            // Initial values of a,b,c,d
            .a(hop_a[gi]),
            .b(hop_b[gi]),
            .c(hop_c[gi]),
            .d(hop_d[gi]),
            // m is a 16th of the full message
            .m(swap_endian_32b(m[g(gi)])),

            .a_out(hop_a[gi+1]),
            .b_out(hop_b[gi+1]),
            .c_out(hop_c[gi+1]),
            .d_out(hop_d[gi+1])
        );
    end
endgenerate

/*
*****************************
* 
*****************************
*/

always @ (posedge clk)
begin
    if (reset) begin
        a_out <= 0;
        b_out <= 0;
        c_out <= 0;
        d_out <= 0;
    end else begin
        if (en) begin
            a_out <= a0 + hop_a[64];
            b_out <= b0 + hop_b[64];
            c_out <= c0 + hop_c[64];
            d_out <= d0 + hop_d[64];
        end
    end
end

endmodule

