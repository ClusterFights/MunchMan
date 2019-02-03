# Level 4 : Blinky
![level3_Blinky](../images/level4_Blinky.png)

## Description

Level 4 Munchman Blinky, is using the same hardware has Level 3 MiniWheat.
It is in the (<$250) weight class.  This cluster has two
computing components a [Raspberry Pi 3 Model B V1.2](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)
($35) and the Digilent [Arty S7-50T: Spartan-7 FPGA
Board](https://reference.digilentinc.com/reference/programmable-logic/arty-s7/start) ($119).

The main goal of Level 4 is to update the Verilog md5 core to support variable length
strings. Another goal is to increase the communication speed between the raspberry pi
and the ArtyS7 fpga board.  I have a few ideas on how to do this, including upgrading
from an 8-bit bus to a 16-bit bus.

## TODO

* **[DONE]** Add support for variable length strings to md5core.
* Add a dedicated Done and Match signals to the 8-bit bus.
* Experiment with the -Os optimization flag.
* Switch from RPI 3 Model B to RPI Model B+
* Expand parallel bus to 16-bits.
* Switch to shielded cable between RPI and FPGA.
* Disregard sending strings that contain newlines.
* Sort manifest by files size in ascending order.

