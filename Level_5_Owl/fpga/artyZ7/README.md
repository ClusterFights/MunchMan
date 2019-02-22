# fpga/artyZ7

## Description

This directory implements a md5_hasher project on the
[Arty Z7-20]((https://reference.digilentinc.com/reference/programmable-logic/arty-z7/start) board from Digilent.

It is implemented using the Xilinx Vivado 2018.3 tools running
on Ubuntu 18.04 OS.

## Results 

## Building the Project

You need to have the [Vivado Digilent board files](https://reference.digilentinc.com/reference/software/vivado/board-files?redirect=1)
installed.  You can get these from this [repo](https://github.com/Digilent/vivado-boards) 
on github.

Instead of storing the whole Vivado project in github
we store only a Tcl script which can generate the Vivado
project.  For more information see

[Version control for Vivado project](http://www.fpgadeveloper.com/2014/08/version-control-for-vivado-projects.html)

Here are the steps to build the project and start vivado on a
Linux system.

```
> source /opt/Xilinx/Vivado/2018.3/settings64.sh
> cd vivado_prj
> ./build.sh
> vivado project_1/project_1.xpr
```

## Export Hardware

After bitstream generation export the hardware description
and bitstream. This is done via File->Export->Export Hardware

Make sure check "Include Bitstream".  Export to
the directory "Level_5_Owl/exported_hw".  This will
write the file design_1_wrapper.hdf to that directory.

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

