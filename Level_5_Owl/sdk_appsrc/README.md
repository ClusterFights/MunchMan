# sdk_appsrc

This is the Xilinx SDK workspace.  The Xilinx SDK
is a customized version of the Eclipse IDE.

These instructions are a modified version of the
instructions found in [this article](http://www.fpgadeveloper.com/2014/02/how-to-download-build-github-fpga-projects.html)

## How to make use of these files

In order to make use of these source files, you must first generate
the Vivado project hardware design (the bitstream) and export the design
to SDK. Check the Level_5_Owl/fpga/artyZ7/README.md for instructions.

Once the bitstream is generated and exported to SDK, you can
launch the SDK from Vivado and import the SDK projects
into the sdk_appsrc workspace.

## Launch SDK

After export the hardware you can launch the SDK via
File->Launch SDK.

For the Exported location: .../Level_5_Owl/exported_hw

Workspace: ...Level_5_Owl/sdk_appsrc

After the SDK launchs import the two projects via

File->Import->General->Existing Projects into Workspace

Select root directory: sdk_appsrc

Select the following two projects
1. md5_hasher
2. md5_hasher_bsp

Leave all the other options unchecked and click Finish.


## Build and run your application

Before trying to run your code, wait a while for SDK to build the
application. It should be automatic, but if it doesn't start by
itself, you can always select Project->Build All. It can sometimes
take a while, check the progress at the bottom right corner of the
SDK window.

## To run the application:

1. Power up your hardware platform and ensure that the JTAG is
connected properly.
2. Select Xilinx Tools->Program FPGA. You only have to do this
once, each time you power up your hardware platform.
3. Setup the SDK Terminal for serial communication.  Click
The + button, and select to the serial port (i.e. /dev/ttyUSB1 )
at 115200 baud.  You could also use another program like putty
or screen (screen /dev/ttyUSB1 115200).
4. Right click on the md5_hasher project and select 
Run As-> Launch on Hardware (System Debugger).
After the first run you can use Run->Run to run the
same program again.

