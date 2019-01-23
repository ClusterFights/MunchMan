/*  
data_test.c

This program sends sequential bytes 0..255 over
the parallel interface to the ArtyS7 board.
It then reads one byte back.  1 indicates success,
0 fail.

Author: Brandon Blodget
Create Date: 01/22/2019

Compile:
 gcc $GPIO_BASE -Wall -o data_test data_test.c && sudo chown root data_test && sudo chmod +s data_test

Run:
 ./data_test

*/
#include <stdio.h>
#include <time.h>
#include <sys/time.h>

#define PI_GPIO_ERR  // errno.h
#include "PI_GPIO.c" // stdio.h, sys/mman.h, fcntl.h, stdlib.h - signal.h

#define DATA0   (21)
#define DATA1   (20)
#define DATA2   (16)
#define DATA3   (12)
#define DATA4   (25)
#define DATA5   (24)
#define DATA6   (23)
#define DATA7   (18)
#define RNW     (26)
#define CLK     (19)

unsigned int set_reg = 0;
unsigned int clr_reg = 0;

struct timespec ns; 

void sleep_ms(int ms) 
{
    struct timespec ts; 
    ts.tv_sec = ms / 1000;
    ts.tv_nsec = (ms % 1000) * 1000000;
    nanosleep(&ts, NULL);
}

/*
 * Used to sync with FPGA.  Set the whole parallel bus to zeros.
 */
void sync_bus()
{
    GPIO_SET_N(CLK);
    /*
    GPIO_CLR_N(RNW);

    GPIO_SET_N(DATA0);
    GPIO_CLR_N(DATA1);
    GPIO_SET_N(DATA2);
    GPIO_CLR_N(DATA3);

    GPIO_SET_N(DATA4);
    GPIO_CLR_N(DATA5);
    GPIO_SET_N(DATA6);
    GPIO_CLR_N(DATA7);
    */

    // First sync work 0xB8 8'b1011_1000
    GPIO_CLR = (1<<RNW) | (1<<DATA0) | (1<<DATA1) | (1<<DATA2) | (1<<DATA6);
    GPIO_SET = (1<<CLK) | (1<<DATA3) | (1<<DATA4) | (1<<DATA5) | (1<<DATA7);

    sleep_ms(10);

    // Second sync work 0x8B 8'b1000_1011
    GPIO_CLR = (1<<RNW) | (1<<DATA2) | (1<<DATA4) | (1<<DATA5) | (1<<DATA6);
    GPIO_SET = (1<<CLK) | (1<<DATA0) | (1<<DATA1) | (1<<DATA3) | (1<<DATA7);

    sleep_ms(10);
}

/*
 * Set the parallel bus config for writing.
 */
void bus_write_config()
{
    PI_GPIO_config(DATA0, BCM_GPIO_OUT);
    PI_GPIO_config(DATA1, BCM_GPIO_OUT);
    PI_GPIO_config(DATA2, BCM_GPIO_OUT);
    PI_GPIO_config(DATA3, BCM_GPIO_OUT);
    PI_GPIO_config(DATA4, BCM_GPIO_OUT);
    PI_GPIO_config(DATA5, BCM_GPIO_OUT);
    PI_GPIO_config(DATA6, BCM_GPIO_OUT);
    PI_GPIO_config(DATA7, BCM_GPIO_OUT);
    PI_GPIO_config(RNW, BCM_GPIO_OUT);
    PI_GPIO_config(CLK, BCM_GPIO_OUT);
}

/*
 * Set the parallel bus config for reading.
 */
void bus_read_config()
{
    PI_GPIO_config(DATA0, BCM_GPIO_IN);
    PI_GPIO_config(DATA1, BCM_GPIO_IN);
    PI_GPIO_config(DATA2, BCM_GPIO_IN);
    PI_GPIO_config(DATA3, BCM_GPIO_IN);
    PI_GPIO_config(DATA4, BCM_GPIO_IN);
    PI_GPIO_config(DATA5, BCM_GPIO_IN);
    PI_GPIO_config(DATA6, BCM_GPIO_IN);
    PI_GPIO_config(DATA7, BCM_GPIO_IN);
    PI_GPIO_config(RNW, BCM_GPIO_OUT);
    PI_GPIO_config(CLK, BCM_GPIO_OUT);
}

/*
 * Write a byte of data of the parallel interface.
 */
inline void bus_write(unsigned char byte)
{
    // Clear the set and clr variables
    set_reg = 0;
    clr_reg = 0;

    // Setup data
    if (byte & 0x01) set_reg |= (1<<DATA0); else clr_reg |= (1<<DATA0);
    if (byte & 0x02) set_reg |= (1<<DATA1); else clr_reg |= (1<<DATA1);
    if (byte & 0x04) set_reg |= (1<<DATA2); else clr_reg |= (1<<DATA2);
    if (byte & 0x08) set_reg |= (1<<DATA3); else clr_reg |= (1<<DATA3);

    if (byte & 0x10) set_reg |= (1<<DATA4); else clr_reg |= (1<<DATA4);
    if (byte & 0x20) set_reg |= (1<<DATA5); else clr_reg |= (1<<DATA5);
    if (byte & 0x40) set_reg |= (1<<DATA6); else clr_reg |= (1<<DATA6);
    if (byte & 0x80) set_reg |= (1<<DATA7); else clr_reg |= (1<<DATA7);

    // Clock should be set and cleared
    clr_reg |= (1<<CLK);
    set_reg |= (1<<CLK);

    // Clear first, setting clock low
    // Then set, setting clock high
    GPIO_CLR = clr_reg;
    GPIO_SET = set_reg;

    // Seems to be necessary to get consistant results.
    // not sure why.
    GPIO_SET_N(CLK);
}

int main(int argc, char *argv[]) {
    int i;
    struct timeval tv1, tv2;

    ns.tv_sec = 0;
    ns.tv_nsec = 1;

    bus_write_config();

    printf("sleeping... \n");
    sync_bus();
    sleep_ms(1000);

    // Set RNW to write mode (0).
    GPIO_CLR_N(RNW);
    
    printf("done! \n");

    // Send bytes 0..256

    gettimeofday(&tv1, NULL);
    for (i=0; i< 256; i++)
    {
        // XXX printf("i: %d\n",i);
        bus_write((unsigned char)i);
        // Sleep for for a bit
        // XXX sleep_ms(50);
    }
    gettimeofday(&tv2, NULL);

    double total_time = (double) (tv2.tv_usec - tv1.tv_usec) / 1000000 +
    (double) (tv2.tv_sec - tv1.tv_sec);
    printf ("send total time = %f seconds\n", total_time);
    double bytes_per_sec = 256 / total_time;
    printf("send bytes_per_sec: %f\n",bytes_per_sec);

    // Receive bytes.

    // Change the bus direction to read from FPGA
    bus_read_config();

    // Set RNW to read mode (1).
    GPIO_SET_N(RNW);

    sleep_ms(100);

    // Read 256 bytes
    unsigned int read_pins=0;
    unsigned char read_val=0;
    gettimeofday(&tv1, NULL);
    for (i=0; i< 256; i++)
    {
        // drive the clock low
        GPIO_CLR_N(CLK);
        GPIO_CLR_N(CLK);

        // drive the clock high
        GPIO_SET_N(CLK);
        GPIO_SET_N(CLK);

        // Read the data off of the bus
        read_pins = GPIO_LEV;
        read_val =  ((read_pins >> (DATA0-0))&0x01) |
                    ((read_pins >> (DATA1-1))&0x02) |
                    ((read_pins >> (DATA2-2))&0x04) |
                    ((read_pins >> (DATA3-3))&0x08) |

                    ((read_pins >> (DATA4-4))&0x10) |
                    ((read_pins >> (DATA5-5))&0x20) |
                    ((read_pins >> (DATA6-6))&0x40) |
                    ((read_pins >> (DATA7-7))&0x80);

        if (read_val != i) {
            printf("i: %d, read_val: %d\n",i,read_val);
        }

        // Sleep for for a bit
        // XXX sleep_ms(10);
    }
    gettimeofday(&tv2, NULL);

    total_time = (double) (tv2.tv_usec - tv1.tv_usec) / 1000000 +
        (double) (tv2.tv_sec - tv1.tv_sec);
    printf ("recv total time = %f seconds\n", total_time);
    bytes_per_sec = 256 / total_time;
    printf("recv bytes_per_sec: %f\n",bytes_per_sec);
}

