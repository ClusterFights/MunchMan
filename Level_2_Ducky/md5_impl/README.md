# md5_impl

## Description

This directory holds the top level design for the Level 2 Ducky
FPGA implementation.

## Block Diagram

Here is a block diagram of the FPGA architecture.

![FPGA_Architecture](images/Ducky_FPGA_Architecture.png)

## Commands

The cmd_parser module receives 1 byte commands from the
usb to serial interface.  Parameters (multi-byte values) are sent MSB first 
(big endian/network order).
Here is a summary of the commands:

* 0x01 target_hash[127:0] : Set the target hash.  Bytes are sent MSB first.
* 0x02 num[15:0] [byte0, byte1 .. byte[num-1]] : Process 'num' characters/bytes. Returns 0x01 if
  hash found else 0x00.
* 0x03 : Returns byte_pos[15:0] that matched hash followed by the 19 character matched string.



