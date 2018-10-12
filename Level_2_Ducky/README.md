# Level 2 : Ducky

## Description

Munchman Ducky is a SuperMicro (<$75) cluster fighter.  This cluster has two computing components a [Raspberry Pi
Zero W](https://www.raspberrypi.org/products/raspberry-pi-zero-w/) ($10) and a Lattice [iCE40-HX8K Breakout
Board](http://www.latticesemi.com/en/Products/DevelopmentBoardsAndKits/iCE40HX8KBreakoutBoard) ($49).  The
communication between the boards will use USB2.0.  I plan to use the Open Source
[Icestorm](http://www.clifford.at/icestorm/) tools for the iCE40 FPGA development.

## Development

Here is the outline of the development plan.

1.  **Loopback Test**:
- Instantiate a uart in Verilog and verify in simulation.  The uart I am using is from [fpga4fun.com](https://www.fpga4fun.com/SerialInterface4.html).
- Instantiate transmit and receive in the FPGA as a loopback test.
- Write code on the PC to send data over the USB to the FPGA.
- Verify can send and receive data. 
- Figure out max datarate data can be sent and received.

2. **MD5 core**: Write or find a MD5Core and testbench...

3. Integration and app development.

## Simulation

Using [Icarus Verilog (a.k.a iverilog)](http://iverilog.icarus.com/) and 
[GTKWave](http://gtkwave.sourceforge.net/) for simulation. 
I used apt-get to install gtkwave.
I compiled iverilog from source using the [github repo](https://github.com/steveicarus/iverilog).
I compiled from source because the version in the Ubuntu 16.04 apt-get 
did not compile the async.v source. It gave a message about unsupported "static functions".
The latest version in github does not have this problem.
The instruction for compiling iverilog is [here](http://iverilog.wikia.com/wiki/Installation_Guide).
Here is a summary of the commands I used to compile iverilog on Ubuntu 16.04.

```
$ sudo apt-get install gperf libreadline-dev valgrind
$ git clone git@github.com:steveicarus/iverilog.git
$ cd iverilog
$ sh autoconf.sh
$ ./configure --with-valgrind
$ make
$ sudo make install
```

There are other prerequisites packages you may need to install.  Check the github repo readme.  Also you
can uninstall if you are in the iverilog directory via

```
$ cd iverilog
$ sudo make uninstall
```

## FTDI library

I compiled [libftdi](https://www.intra2net.com/en/developer/libftdi/) from source. I got the source via

```
$ git clone git://developer.intra2net.com/libftdi
```

Build instructions in the README and README.build
