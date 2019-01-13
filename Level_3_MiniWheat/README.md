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

## Development

Here is the outline of the development plan.

1.  **GPIO Output Test**:
- Write FPGA firmware that connects 4 GPIOs on the Arty-S7 board directly to LEDs.
- Write code on the the Raspberry Pi that drives the 4 leds from the RPi GPIO.
- Figure out max datarate that can be written.

2. **GPIO Input Test**: 

3. **GPIO by directional Test**:

4. **Update Level 2 code to use Parallel interface.**

