# Level 5 : Owl
![level5_Owl](../images/level5_Owl.png)

## Description

Level 5 Munchman Owl is similar to Level 4 Blinky but the FPGA board
has been upgraded from the Arty S7-50T to the Arty Z7-20.
It is still in the (<$250) weight class.  This cluster has two
computing components a [Raspberry Pi 3 Model B V1.2](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)
($35) and the Digilent [Arty Z7-20]: Zynq-20 FPGA
Board](https://reference.digilentinc.com/reference/programmable-logic/arty-z7/start) ($199).

The main goal of Level 5 is to use the 512MB of DDR ram to cache the 400MB dataset
locally. The ArtyZ7 has less pmod connectors than the ArtyS7 so the interface
to the RPI board will go back to the 8-bit parallel interface.  The initial plan
is not to use the dual core Cortex A9 processors that are on the Zynq.

## 8-bit Parallel Interface

This interface is an 8-bit parallel, synchronous, master interface.
The RPI is the master and controls the clock.  Data must be valid on the
rising edge of the clock.  In this update we add two more wires, a
**done** signal and a **match** signal.  These signals are outputs from
the FPGA and inputs to the RPI.  This way we do not have to change
the direction of the data bus to get an acknowledge.

| Signal Name   | RPI GPIO  | ArtyZ7     |
| ------------- |:---------:| ----------:|
| data0         | 21        | JA(1) Y18  |
| data1         | 20        | JA(3) Y16  |
| data2         | 16        | JA(5) U18  |
| data3         | 12        | JA(7) W18  |
| data4         | 25        | JB(3) T10  |
| data5         | 24        | JB(4) T11  |
| data6         | 23        | JB(5) W16  |
| data7         | 18        | JB(7) W13  |
| r/w           | 26        | JA(2) Y19  |
| clk           | 19        | JB(2) W14  |
| done          | 13        | JA(4) Y17  |
| match         | 6         | JB(4) T11  |


## TODO

* Build a simple blinky led design for the ArtyZ7 board.

* Build 9-bit parallel interface to blink leds.

* Port the exisiting Level4 design the the ArtyZ7 board.

* Add DDR memory to the design

* Add ability to write to DDR from the RPI.

* Update the design to process the dataset from DDR.


