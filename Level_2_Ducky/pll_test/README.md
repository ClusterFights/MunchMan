# PLL_TEST

## Description

A test to use a pll to increase the clock rate from
the base 12mhz on the iCE40HX-8K demo board.
The Lattice iCEcube2 tools install
a command line program called "icepll" that will
generate a verilog module for the pll.

For example the following command generates a verilog
module that takes a 12mhz clock in and generates
a 72mhz clock on the output.

```
$ icepll -i 12 -o 72 -m -f pll_72mhz.v
```

This [blog post](https://mjoldfield.com/atelier/2018/02/ice40-blinky-hx8k-breakout.html) has more information.

