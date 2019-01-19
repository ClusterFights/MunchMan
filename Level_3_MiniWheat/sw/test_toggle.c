/*  
test_toggle.c

Toggles pin 21 on the rpi.

Compile:
 gcc $GPIO_BASE -Wall -o test_toggle test_toggle.c && sudo chown root test_toggle && sudo chmod +s test_toggle

Run:
 ./test_toggle

*/
#include <time.h>

#define PI_GPIO_ERR  // errno.h
#include "PI_GPIO.c" // stdio.h, sys/mman.h, fcntl.h, stdlib.h - signal.h
#define PI_OUT (21)

void sleep_ms(int ms) 
{
    struct timespec ts; 
    ts.tv_sec = ms / 1000;
    ts.tv_nsec = (ms % 1000) * 1000000;
    nanosleep(&ts, NULL);
}

int main(int argc, char *argv[]) {
    int state=0;
    PI_GPIO_config(PI_OUT, BCM_GPIO_OUT);

    while (1)
    {
        if (state==1)
        {
            GPIO_SET_N(PI_OUT);
            state=0;
        } else
        {
            GPIO_CLR_N(PI_OUT);
            state=1;
        }
        // Sleep for .5 seconds
        sleep_ms(500);
    }
}

