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

static unsigned char test_str[] = "Hello. The quick brown fox jumps over the lazy dog.";

// test_str length is 51 = 0x33.
static int test_str_len = 51; // bytes {0x00, 0x33};

// Hold the match result
static struct match_result match;

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

    // Initialize the ftdi.
    printf("Initialize ftdi\n");
    ftdi_setup(ftdi);

    // Read anything that is hanging around.
    printf("Clear input char queue.\n");
    clear_ftdi(ftdi);

    // Send the test command 0x04.
    printf("Sending the test command 0x04.\n");
    cmd_test(ftdi);

    // Send the set hash command 0x01.
    printf("Sending the set hash command 0x01.\n");
    cmd_set_hash(ftdi, target_hash);

    // Send the send text command 0x02.
    printf("Sending the send text command 0x02.\n");
    cmd_send_text(ftdi, test_str, test_str_len);

    // Send the command to read match data, 0x03.
    printf("\nSent command to read match data, 0x03.\n");
    cmd_read_match(ftdi, &match);
    printf("match.pos = %d \n",match.pos);
    printf("match.str = %s \n",match.str);

    // Close connections
    printf("Close the ftdi_usb.\n");
    ret = ftdi_usb_close(ftdi);
    if (ret < 0)
    {
        printf("unable to close ftdi: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
    }

    return EXIT_SUCCESS;
}


