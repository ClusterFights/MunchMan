# Level 3 : MiniWheat

## Description

Level 3 Munchman MiniWheat has evolved from level 2. It has moved up to the (<$250) weight class.  This cluster has two
computing components a [Raspberry Pi 3 Model B V1.2](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)
($35) and the Digilent [Arty S7-50T: Spartan-7 FPGA
Board](https://reference.digilentinc.com/reference/programmable-logic/arty-s7/start) ($119).

The goal of Level 3 is to update the communication between the Raspberry Pi and the FPGA board from USB to a parallel
interface using the Raspberry Pi GPIOs.

To start with I'm going try the [C GPIO library for Raspberry
Pi](https://hackaday.io/project/17066-c-gpio-library-for-raspberry-pi) for the parallel interface.

## Parallel Interface

This interface is an 8-bit parallel, synchronous, master interface.
The RPI is the master and controls the clock.  Data must be valid on the
rising edge of the clock.  Down the road we may play with transfering data
on both clock edges.

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
| R/W           | 26        | JB(1) P17  |
| CLK           | 19        | JB(2) P18  |

## Results

The GPIO_output_test is able to toggle a single RPI GPIO pin at about 30MHz!  To
get this performance the C test code has to be compiled with the -O3 optimization flag.

The Data_Send_Test was able to send a byte from the RPI to the FPGA at a
about 10MB per second.  The FPGA is able to send data back to the RPI at about 5MB per second.
Sending/receiving a byte has much more overhead than toggling a single pin.

## Development

Here is the outline of the development plan.

1.  **GPIO Output Test**:
- Write FPGA firmware that connects 4 GPIOs on the Arty-S7 board directly to LEDs.
- Write code on the the Raspberry Pi that drives the 4 leds from the RPi GPIO.
- Figure out max datarate that can be written.

2. **Data Send Test**: The RPI send sequential bytes 0..255 to the fpga.  The FPGA
checks that it receives 256 sequential bytes.  If success green led[0] is turned on.
The FPGA then sends bytes 0..255 to the RPI.

3. **Update Level 2 code to use Parallel interface.**

