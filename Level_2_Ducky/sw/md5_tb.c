/*
 * FILE : md5_tb.c
 *
 * This software tests the FPGA firmware
 * impl/top_md5.  It is basically a C version
 * of the Verilog testbench found in
 * sim/top_tb.  
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 11/04/2018
 */

#include "munchman.h"

// target md5 hash for "The quick brown fox"
static unsigned char target_hash[] = {
    0xa2, 0x00, 0x4f, 0x37,
    0x73, 0x0b, 0x94, 0x45,
    0x67, 0x0a, 0x73, 0x8f,
    0xa0, 0xfc, 0x9e, 0xe5
};

static unsigned char test_str[] = "Hello. The quick brow fox jumps over the lazy dog.";

static unsigned char ret_buffer[100] = {0};

int main(int argc, char *argv[])
{
    struct ftdi_context *ftdi;
    struct ftdi_version_info version;
    int ack;
    int ret;

    // Setup the FTDI connections
    printf("Setup ftdi\n");
    if ((ftdi = ftdi_new()) == 0)
    {
        printf("ftdi_new failed\n");
        return EXIT_FAILURE;
    }
    version = ftdi_get_library_version();
    printf("Initialized libftdi %s (major: %d, minor: %d, micro: %d, snapshot version : %s)\n",
            version.version_str, version.major, version.minor, version.micro,
            version.snapshot_str);
    printf("Created new ftdi\n");

    ftdi_setup(ftdi);
    printf("ftdi initialized\n");

    // Send the target hash.
    ret = ftdi_write_data(ftdi, "\x01", 1); // cmd
    if (ret != 1)
    {
        printf("Error during ftdi_write_data: %d != %d\n",ret,1);
    }
    ret = ftdi_write_data(ftdi, target_hash, 16); //data
    if (ret != 16)
    {
        printf("Error during ftdi_write_data: %d != %d\n",ret,16);
    }
    // Read the ACK.
    ack = ret_buffer[0];
    printf("before read. ack=%x\n",ack);
    ret = ftdi_read_data(ftdi, ret_buffer, 100);
    if (ret > 0) {
        ack = ret_buffer[0];
        printf("Read ACK. ret=%d, ack=%x\n",ret,ack);
    } else {
        printf("ERROR Read ACK. ret=%d, ack=%x\n",ret,ack);
    }

    // Close connections
    ret = ftdi_usb_close(ftdi);
    if (ret < 0)
    {
        printf("unable to close ftdi: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
    }

    return EXIT_SUCCESS;
}


