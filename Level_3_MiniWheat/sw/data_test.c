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


void sleep_ms(int ms) 
{
    struct timespec ts; 
    ts.tv_sec = ms / 1000;
    ts.tv_nsec = (ms % 1000) * 1000000;
    nanosleep(&ts, NULL);
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

    // Set the clock to low
    GPIO_CLR_N(CLK);

    // Set the rnw high
    GPIO_SET_N(RNW); 
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

    // Set the clock to low
    GPIO_CLR_N(CLK);
}

/*
 * Write a byte of data of the parallel interface.
 */
void bus_write(unsigned char byte)
{
    // Set the clock to low
    GPIO_CLR_N(CLK);

    // Set RNW to write mode (0).
    GPIO_CLR_N(RNW);

    // Setup data
    if (byte & 0x01) GPIO_SET_N(DATA0); else GPIO_CLR_N(DATA0);
    if (byte & 0x02) GPIO_SET_N(DATA1); else GPIO_CLR_N(DATA1);
    if (byte & 0x04) GPIO_SET_N(DATA2); else GPIO_CLR_N(DATA2);
    if (byte & 0x08) GPIO_SET_N(DATA3); else GPIO_CLR_N(DATA3);
    if (byte & 0x10) GPIO_SET_N(DATA4); else GPIO_CLR_N(DATA4);
    if (byte & 0x20) GPIO_SET_N(DATA5); else GPIO_CLR_N(DATA5);
    if (byte & 0x40) GPIO_SET_N(DATA6); else GPIO_CLR_N(DATA6);
    if (byte & 0x80) GPIO_SET_N(DATA7); else GPIO_CLR_N(DATA7);

    // Assert the CLK
    GPIO_SET_N(CLK);
}

int main(int argc, char *argv[]) {
    int i;
    struct timeval tv1, tv2;
    bus_write_config();

    gettimeofday(&tv1, NULL);
    for (i=0; i< 256; i++)
    {
        printf("i: %d\n",i);
        bus_write((unsigned char)i);
        // Sleep for 1 seconds
        sleep_ms(1000);
    }
    gettimeofday(&tv2, NULL);

    double total_time = (double) (tv2.tv_usec - tv1.tv_usec) / 1000000 +
    (double) (tv2.tv_sec - tv1.tv_sec);
    printf ("Total time = %f seconds\n", total_time);
    double bytes_per_sec = 256 / total_time;
    printf("bytes_per_sec: %f\n",bytes_per_sec);

}

