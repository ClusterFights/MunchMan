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

## Parallel Interface Update

This interface is an 8-bit parallel, synchronous, master interface.
The RPI is the master and controls the clock.  Data must be valid on the
rising edge of the clock.  In this update we add two more wires, a
**done** signal and a **match** signal.  These signals are outputs from
the FPGA and inputs to the RPI.  This way we do not have to change
the direction of the data bus to get an acknowledge.

The following table shows the connections between the RPI and the ArtyS7 board.

| Signal Name   | RPI GPIO  | ArtyS7     |
| ------------- |:---------:| ----------:|
| data0         | 21        | JA(1) L17  |
| data1         | 20        | JA(2) L18  |
| data2         | 16        | JA(3) M14  |
| data3         | 12        | JA(4) N14  |
| data4         | 25        | JA(7) M16  |
| data5         | 24        | JA(8) M17  |
| data6         | 23        | JA(9) M18  |
| data7         | 18        | JA(10) N18 |
| r/w           | 26        | JB(1) P17  |
| clk           | 19        | JB(2) P18  |
| done          | 13        | JB(7) P14  |
| match         | 6         | JB(8) P15  |


## TODO

* **[DONE]** Add support for variable length strings to md5core.

Supports hashing variables length strings from 2 to 55 characters.

* **[DONE]** Add a dedicated Done and Match signals to the 8-bit bus.

This change really improved the throughput on the bus. It
used to run at about 5MB/sec now it is about 20MB/sec!

* Sort manifest by files size in ascending order.
* Disregard sending strings that contain newlines.
* Add **close** command to disconnect from parallel bus
* Expand parallel bus to 16-bits.
* Switch to shielded cable between RPI and FPGA.
* Experiment with the -Os optimization flag.
* Switch from RPI 3 Model B to RPI Model B+

