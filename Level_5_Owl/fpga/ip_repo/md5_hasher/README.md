# md5_hasher

### Description

This module implements a MD5 hasher.  It hashes strings
of a specified length, set through the control interface.
A target hash also can be set through the control interface.
It reads characters from an AXI stream and computes
hashes of the specified length until a match to the target
hash is found or the end of the stream.  If the target hash
is found the string that produced that hash is sent through
the an output AXI stream.


### Control status registers

* reg0 : (W) Control Register
    * Bit 0 - reset core (auto clear)
    * Bit 1 - Start procesing chars (auto clear)
    * Bit 2 - Clear the match interrupt (auto clear)
* reg1 : (R) Status Register
    * Bit 0 - Busy
    * Bit 1 - Done
    * Bit 2 - Match interrupt.
* reg2 : (W) Target Hash 0 (most sig word)
* reg3 : (W) Target Hash 1
* reg4 : (W) Target Hash 2
* reg5 : (W) Target Hash 3 (least sig word)
* reg6 : (W) String Length
* reg7 : (R) Byte position of match.

