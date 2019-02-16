# MunchMan
![munchman icon](images/munchman_icon.png)

_Munch Man munches data as fast as he can_

Inspired by the classic 80's game of the same name for the TI-99/4a.

## Description

Munch Man is a [ClusterFigher](http://clusterfights.com/wiki/index.php?title=Main_Page).
The plan is to start simple and level up over time.  

![level1_spinny](images/level1_spinny.png)
__Level_1_Spinny__ : Python scripts for generating a
manifest of the Project Guttenberg dataset, selecting a
random string from the dataset and returns the md5 hash,
and finding a string from the dataset the matches a given md5
hash.

![level2_ducky](images/level2_ducky.png)
__Level_2_Ducky__ : Development of a verilog md5 hash
core.  Initially attempt to target the Lattice ICE40HX8K
breakout board but the core was too big. Switched to the Digilent
ArtyS7 fpga board. Used USB to communicate between the
raspberry pi and ArtyS7 board.  But USB 2.0 was too slow
for real acceleration.

![level3_MiniWheat](images/level3_MiniWheat.png)
__Level_3_MiniWheat__ : Developed an 8-bit parallel
interface between the raspberry pi and the ArtyS7 board.
This configuration was able to stream text from the RPI to
the ArtyS7 and perform 5.4M hashes per second.  This was
good enough to win 2 out of 3 rounds at the ClusterFight
held on 01/26/2019.

![level4_Blinky](images/level4_Blinky.png)
__Level_4_Blinky__ : Updated the md5 hash algorithm to
support hashing strings of length 2 to 55 characters.
Developed a 16-bit parallel interface with dedicated
done and match signals. Capable of almost 60M hashes
per second.  Over 10x improvement of level3.

![level5_Owl](images/level5_Owl.png)
__Level_5_Owl__ : In development ...

