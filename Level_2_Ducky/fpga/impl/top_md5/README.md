# md5_impl

## Description

This directory holds the top level design for the Level 2 Ducky
FPGA implementation.

## Status

The ice40 implementation fails because the design is too big
by at least a factor of 2.

Currently debugging the arty_s7 implementation.  The
bitstream gets generated OK.  When sending commands
the ACK byte gets returned as 0xe5 when it should be
0x01.


## Block Diagram

Here is a block diagram of the FPGA architecture.

![FPGA_Architecture](images/Ducky_FPGA_Architecture.png)

## Commands

The cmd_parser module receives 1 byte commands from the
usb to serial interface.  Parameters (multi-byte values) are sent MSB first 
(big endian/network order).
Here is a summary of the commands:

* 0x01 target_hash[127:0] : Set the target hash.  Bytes are sent MSB first. Returns ACK (0x01).
* 0x02 num[15:0] [byte0, byte1 .. byte[num-1]] : Process 'num' characters/bytes. Returns ACK (0x01) if
  hash found else (0x00).
* 0x03 : Returns byte_pos[15:0] that matched hash followed by the 19 character matched string. So 21 bytes in total. No ACK/NACK
* 0x04 : Test command.  Returns ten bytes 10, 9, 8, 7, ... 1.



