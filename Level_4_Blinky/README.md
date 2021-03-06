# Level 4 : Blinky
![level4_Blinky](../images/level4_Blinky.png)

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
| data0         | 21        | JC(1) U15  |
| data1         | 20        | JC(2) V16  |
| data2         | 16        | JC(3) U17  |
| data3         | 12        | JC(4) U18  |
| data4         | 25        | JC(7) U16  |
| data5         | 24        | JC(8) P13  |
| data6         | 23        | JC(9) R13  |
| data7         | 18        | JC(10) V14 |
| data8         | 5         | JD(3) V13 |
| data9         | 11        | JD(4) T12 |
| data10        | 9         | JD(9) T11 |
| data11        | 10        | JD(10) U11 |
| data12        | 22        | JB(1) P17 |
| data13        | 27        | JB(3) R18 |
| data14        | 17        | JB(7) P14 |
| data15        | 4         | JB(9) N15 |
| r/w           | 26        | JD(1) V15  |
| clk           | 19        | JD(2) U12  |
| done          | 13        | JD(7) T13  |
| match         | 6         | JD(8) R11  |


**NOTE**: Port JB is a "high speed" port and has differential routing for pin pairs.
Since we are using single ended signals we skip every other port connection. Also
connected a GND between every FPGA Pmod port and the RPI. We also changed
out the series 0 Ohm resisters and replaced them with 200 Ohm resistors on JB.


## TODO

* **[DONE]** Add support for variable length strings to md5core.

Supports hashing variables length strings from 2 to 55 characters.

* **[DONE]** Add a dedicated Done and Match signals to the 8-bit bus.

This change really improved the throughput on the bus. It
used to run at about 5MB/sec now it is about 20MB/sec!

* **[DONE]** Add quite mode to disable printing book titles.

Saves about a second over the whole dataset

* **[SKIPPED]** Disregard sending strings that contain newlines.

Experimented with removing newlines on the fly but it actually
made the execution time slower.  It takes more time to remove
the newlines than to just process them.

* **[DONE]** Add **close** command to disconnect from parallel bus

* **[DONE]** Expand parallel bus to 16-bits.

I was able to clock the 8-bit bus at ~28Mhz.  The 16-bit bus experiences
data corruption at that rate.  I had to slow it down to about ~20Mhz.
So a little less than 40M hashes/sec.  The whole 430MB dataset
is taking about 11.14 seconds.

The data transfer rate between the RPI and the FPGA board
is thus 20Mhz * 2 Bytes * 8 bits = 320Mbits/sec.
This is faster than the ethernet interface which tops
out at 300MBits/sec on the RPI.

I was able to get the clock to clock at 40Mhz but the data
can't transition fast enough.  Maybe if a replaced the 200Ohm
series resistors with smaller values.  At that rate it could
process the dataset at 5.9 seconds but the data was always corrupted.

* **[DONE]** Increase FPGA clock from 100mhz to 150mhz.

The FPGA is now capable of processing 150M hashes/sec.
The purpose of this change was to give me more time
to sample the inputs from the raspberry pi.
But it did not help the overall system performance.

* **[SKIPPED]** Switch to shielded cable between RPI and FPGA.

Looked at this with Jeff.  We made the cables shorter and looked
at them on the scope.  They are looking pretty good.

* **[DONE]** Experiment with the -Os optimization flag.

Looks like -O3 is working better than -Os.

* **[DONE]** Switch from RPI 3 Model B to RPI Model B+

Moving from the B to the B+ seemed to improved
the the processing time of the whole 430MB dataset
from 11.2 seconds to 11.1 seconds.  Not a big improvement.

But I discovered that turning off the serial console
improved the performance from 11.1 seconds to 7.2 seconds!
The theory of the improvement is that enabling the serial
port causes the clock rate to change for the external ports
causing the slow down.  Don't know this for sure however.

* **[Skipped]** Develop microSD card interface for the ARTYS7 board.

I looked at this a little bit.  High speed (50MB/sec or greater)
microSD card access requires changing the voltage levels from 3.3V
to 1.8V.  It has to start at 3.3V logic and then negotate 1.8V
for the high speed.  Changing the voltage levels is not possible
via the Pmod from digilent.  Also to get the 104MB/sec we would
have to read the 4-bit data at 208MHz.  Without having delayed
match lines on the PCB it might not be possible.  Currently
with the 16-bit parallel bus I am transfering data at 66MB/sec
so anything slower is not worthwhile.

* Experiment with overclocking the RPI 3 B+.

* Increase length of stream characters from 16-bits to 32-bits.
Add "bus_kill" signal between RPI and FPGA to stop current operation early.
Separate process to monitor "bus_match" and send signal back to ifind
to stop sending data and assert "bus_kill".

* Add flag to ifind to remove eol characters from being loaded into ram.


