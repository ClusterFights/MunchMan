#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <ftdi.h>
#include "kbinput.h"

void sleep_ms(int ms)
{
    struct timespec ts;
    ts.tv_sec = ms / 1000;
    ts.tv_nsec = (ms % 1000) * 1000000;
    nanosleep(&ts, NULL);
}

int main(void)
{
    int ret;
    struct ftdi_context *ftdi;
    struct ftdi_version_info version;

    if ((ftdi = ftdi_new()) == 0)
    {
        printf("ftdi_new failed\n");
        return EXIT_FAILURE;
    }
    version = ftdi_get_library_version();
    printf("Initialized libftdi %s (major: %d, minor: %d, micro: %d, snapshot version : %s)\n",
            version.version_str, version.major, version.minor, version.micro,
            version.snapshot_str);

    // Set the interface to B which should be the uart.
    ftdi_set_interface(ftdi, INTERFACE_B);

    // Open the ice40 ftdi connection
    if ((ret = ftdi_usb_open(ftdi, 0x0403, 0x6010)) < 0)
    {
        printf("unable to open ftdi device: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
        ftdi_free(ftdi);
        return EXIT_FAILURE;
    }

    // Set the BAUD rate
    if ((ret = ftdi_set_baudrate(ftdi, 115200)) < 0)
    {
        printf("unable to set baudrate: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
        ftdi_free(ftdi);
        return EXIT_FAILURE;
    }

    char write_buf[1];
    char read_buf[1];
    write_buf[0] = 1;
    read_buf[0] = 2;
    while (1)
    {
        // Write some data.
        ret = ftdi_write_data(ftdi, write_buf, 1);
        if (ret < 0)
        {
            printf("unable to send data: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
            ftdi_free(ftdi);
            return EXIT_FAILURE;
        }

        // Sleep for 5ms
        sleep_ms(5);

        // Read some data
        ret = ftdi_read_data(ftdi, read_buf, 1);
        if (ret < 0)
        {
            printf("unable to read data: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
            ftdi_free(ftdi);
            return EXIT_FAILURE;
        }
        printf("\nread_buf[0]: %#x \n",read_buf[0]);

        // Get a keyboard press
        write_buf[0] = kbinput_read_block(10);
        if (write_buf[0]=='q' || write_buf[0] == -1) {
            write_buf[0] = 0;
            ftdi_write_data(ftdi, write_buf, 1);
            break;
        }
        printf("\nwrite_buf[0]: %#x \n",write_buf[0]);
    }

    // Close the connection
    ret = ftdi_usb_close(ftdi);
    if (ret < 0)
    {
        printf("unable to close ftdi: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
        ftdi_free(ftdi);
        return EXIT_FAILURE;
    }

    ftdi_free(ftdi);
    return EXIT_SUCCESS;

}
