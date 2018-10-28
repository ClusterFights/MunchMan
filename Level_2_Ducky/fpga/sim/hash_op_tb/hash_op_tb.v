/*
*****************************
* MODULE : hash_op_tb
*
* Testbench for the hash_op module.
*
* Author : Brandon Bloodget
* Create Date : 10/11/2018
*
*****************************
*/

// Force error when implicit net has no type.
`default_nettype none

`timescale 1 ns / 1 ps

`define TESTBENCH

module hash_op_tb;

// Inputs (registers)
reg clk_12mhz;
reg reset;
reg en;
reg valid_in;


// Outputs (wires)
wire [31:0] a_out;
wire [31:0] b_out;
wire [31:0] c_out;
wire [31:0] d_out;
wire valid_out;


/*
*****************************
* Parameters
*****************************
*/

// Define the message
// mesg1="The quick brown fox"
localparam [151:0] mesg1 = 152'h54686520_71756963_6b206272_6f776e20_666f78;

// For the ClusterFight competition all MD5 hashes are 19 characters.
// The first bit following the message is '1' hence the 0x80.
// The message is padded to 56 bytes by adding 0's.  The last
// 64-bits hold the original msg length in bits in big endian format.
// The original length is 19 chars = 152 bits = 0x98 bits.
// So the padding to the end of the message is constant.
localparam[359:0] msg_pad = 360'h80_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_98000000_00000000;

// Expected results
localparam [31:0] a_good = 32'h10325476;
localparam [31:0] b_good = 32'hd7d41184;
localparam [31:0] c_good = 32'hefcdab89;
localparam [31:0] d_good = 32'h98badcfe;

/*
*****************************
* Instantiation (DUT)
*****************************
*/

// Simulation of stage/index 0.
hash_op #
(
    .index(0),
    .s(7),
    .k(32'hd76aa478),
    .msg_pad(msg_pad)
) hash_op_inst
(
    .clk(clk_12mhz),
    .reset(reset),
    .en(en),

    // Initial values of a,b,c,d
    .a(32'h67452301),
    .b(32'hefcdab89),
    .c(32'h98badcfe),
    .d(32'h10325476),
    // m_in is only the 19 character (152 bits)
    // of the msg.  msg_pad holds the rest.
    .m_in(mesg1),
    .valid_in(valid_in),

    .a_out(a_out),
    .b_out(b_out),
    .c_out(c_out),
    .d_out(d_out),
    .valid_out(valid_out)
);

/*
*****************************
* Main
*****************************
*/
initial begin
    $dumpfile("hash_op.vcd");
    $dumpvars;
    clk_12mhz = 0;
    reset = 0;

    // Wait 100ns
    #100;
    // Add stimulus here
    @(posedge clk_12mhz);
    reset = 1;
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
    reset = 0;
    @(posedge clk_12mhz);
    @(posedge clk_12mhz);
end


// Generate a ~12mhz clk
always begin
    #41 clk_12mhz <= ~clk_12mhz;
end

// Run the testbench
reg [7:0] tb_state;
reg [7:0] tb_next_state;
reg [10:0] tb_char_count;
reg [7:0] tb_lat_count;

localparam IDLE                 = 0;
localparam EXTRA_CLOCKS         = 1;
localparam ENABLE               = 2;
localparam ASSERT_VALID_IN      = 3;
localparam DEASSERT_VALID_IN    = 4;
localparam CHECK                = 5;
localparam FINISH               = 6;

always @ (posedge clk_12mhz)
begin
    if (reset) begin
        en <= 0;
        valid_in <= 0;
        tb_state <= IDLE;
        tb_next_state <= IDLE;
        tb_char_count <= 0;
        tb_lat_count <= 0;
    end else begin
        case (tb_state)
            IDLE : begin
                en <= 0;
                tb_lat_count <= 0;
                valid_in <= 0;
                tb_char_count <= 4;
                tb_state <= EXTRA_CLOCKS;
                tb_next_state <= ENABLE;
            end
            EXTRA_CLOCKS : begin
                tb_char_count <= tb_char_count - 1;
                if (tb_char_count == 0) begin
                    tb_char_count <= 54;
                    tb_state <= tb_next_state;
                end
            end
            ENABLE : begin
                en <= 1;
                tb_char_count <= 4;
                tb_state <= EXTRA_CLOCKS;
                tb_next_state <= ASSERT_VALID_IN;
            end
            ASSERT_VALID_IN : begin
                valid_in <= 1;
                tb_lat_count <= 0;
                tb_state <= DEASSERT_VALID_IN;
            end
            DEASSERT_VALID_IN : begin
                valid_in <= 0;
                tb_lat_count <= tb_lat_count + 1;
                if (valid_out) begin
                    tb_lat_count <= tb_lat_count;
                    tb_state <= CHECK;
                end
            end
            CHECK : begin
                $display("latency: %d",tb_lat_count);
                $display("a_out: %d, a_good: %d",a_out,a_good);
                $display("b_out: %d, b_good: %d",b_out,b_good);
                $display("c_out: %d, c_good: %d",c_out,c_good);
                $display("d_out: %d, d_good: %d",d_out,d_good);
                if ( (a_out == a_good) && (b_out == b_good) &&
                     (c_out == c_good) && (d_out == d_good) ) begin
                    $display("PASSED TEST");
                end else begin
                    $display("FAILED TEST");
                end
                tb_char_count <= 4;
                tb_state <= EXTRA_CLOCKS;
                tb_next_state <= FINISH;
            end
            FINISH : begin
                $finish;
            end
            default : begin
                tb_state <= IDLE;
            end
        endcase
    end
end


endmodule

