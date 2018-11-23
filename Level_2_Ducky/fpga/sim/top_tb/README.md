# md5_impl/sim

## Status

__GOOD__ : The 'make run' target works.  The 'make view'
waveform is out of date but you can add the signals
you want to see.

## Description

This directory basicaly simulates the whole top_md5
design.  The testbench contains task which implement
the cmd_set_hash, cmd_send_text, and cmd_read_match.
It also has a task, send_file, which breaks the text
file alice30.txt into chunks and sends it into the
design. The size of the chunks are determined by the
parameter BUFFER_SIZE.

The testbench has a uart which converts the
streaming char bytes into a serial stream.  Likewise
it reads the output serial stream into bytes.

* __compile__ : Default target. Compiles without running the simulation.  Good way to
  test for syntax errors.
* __run__ : Runs the simulation. Outputs PASS or FAIL to standard out.
  Generates a waveform vcd file.
* __view__ : Runs gtkwave and displays the waveform.
* __clean__ : Remove the generated files
* __help__ : Displays iverilog help

## Output

```
> make run
...
vvp sim_top.vvp
VCD info: dumpfile sim_top.vcd opened for output.
r:      163184
feof:          1

                 155: BEGIN cmd_set_hash
               15235: BEGIN read_ack
               17005: END read_ack
               17005 cmd_state=00
               17005 target_hash=7e2ba776cc7b346f3592bfedb41b18bd
               17005: END cmd_set_hash

               17025: BEGIN send_file
               17025: full transfer:           0:        199

               17025: BEGIN cmd_send_text
               18005: MSB len=00
               18945: LSB len=c8
***This is the Project Gutenberg Etext of Alice in Wonderland***
*This 30th edition should be labeled alice30.txt or alice30.zip.
***This Edition Is Being Officially Released On March 8, 1994***
**              206945: BEGIN read_ack
              212605: END read_ack
              212605: END cmd_send_text
              212605: MATCH FOUND!!
              212605: END send_file

              212615: BEGIN cmd_read_match
              212655: Read byte position
              215365: Read match string
              233215: match_pos:   100
              233215: match_str: ' ed alice30.txt or a'
              233215: END cmd_read_match
```



