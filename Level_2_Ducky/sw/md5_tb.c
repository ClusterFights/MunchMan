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
static unsigned char test_str_len[] = {0x00, 0x33};

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

    // Read anything that is hanging around.
    printf("Clear input char queue.\n");
    ret = ftdi_read_data(ftdi, ret_buffer, 100);
    if (ret > 0) {
        printf("WARN, read some data ret=%d\n",ret);
    } else {
        printf("OK. No data waiting.\n");
    }
    // XXX printf("press Enter\n");
    // XXX getchar();

    // Send the test command 0x04.
    printf("Sending the test command 0x04.\n");
    ret = ftdi_write_data(ftdi, "\x04", 1); // cmd
    if (ret != 1)
    {
        printf("Error during ftdi_write_data: %d != %d\n",ret,1);
    }
    // XXX printf("press Enter\n");
    // XXX getchar();


    // Read the test bytes 10,9,8..1
    printf("Read the test bytes 10,9,8..1.\n");
    ret = ftdi_read_data(ftdi, ret_buffer, 100);
    if (ret > 0) {
        printf("Num of bytes read=%d\n",ret);
        for (int i=0; i<ret; i++)
        {
            printf("%d: %x\n",i,ret_buffer[i]);
        }
    } else {
        printf("ERROR ret=%d\n",ret);
    }
    // XXX printf("press Enter\n");
    // XXX getchar();


    // Send the set hash command 0x01.
    printf("Sending the set hash command 0x01.\n");
    ret = ftdi_write_data(ftdi, "\x01", 1); // cmd
    if (ret != 1)
    {
        printf("Error during ftdi_write_data: %d != %d\n",ret,1);
    }
    // XXX printf("press Enter\n");
    // XXX getchar();

    // Send the target hash.
    printf("Send the target hash.\n");
    ret = ftdi_write_data(ftdi, target_hash, 16); //data
    if (ret != 16)
    {
        printf("Error during ftdi_write_data: %d != %d\n",ret,16);
    }
    // XXX printf("press Enter\n");
    // XXX getchar();


    // Read the ACK.
    printf("Read the ACK.\n");
    ack = ret_buffer[0];
    printf("before read. ack=%x\n",ack);
    ret = ftdi_read_data(ftdi, ret_buffer, 100);
    if (ret > 0) {
        ret_buffer[0] = 0;
        ack = ret_buffer[0];
        printf("Read ACK. ret=%d, ack=%x\n",ret,ack);
    } else {
        printf("ERROR Read ACK. ret=%d, ack=%x\n",ret,ack);
    }
    // XXX printf("press Enter\n");
    // XXX getchar();


    // Send the send data command 0x02.
    printf("Sending the send data command 0x02.\n");
    ret = ftdi_write_data(ftdi, "\x02", 1); // cmd
    if (ret != 1)
    {
        printf("Error during ftdi_write_data: %d != %d\n",ret,1);
    }
    // XXX printf("press Enter\n");
    // XXX getchar();

    // Send the number of bytes to be sent.
    printf("Send the number of bytes to be sent.\n");
    ret = ftdi_write_data(ftdi, test_str_len, 2);
    if (ret != 2)
    {
        printf("Error during ftdi_write_data: %d != %d\n",ret,16);
    }
    // XXX printf("press Enter\n");
    // XXX getchar();

    // Send the string.
    printf("Sending the test string.\n");
    ret = ftdi_write_data(ftdi, test_str, 51);
    if (ret != 51)
    {
        printf("Error during ftdi_write_data: %d != %d\n",ret,16);
    }
    // XXX printf("press Enter\n");
    // XXX getchar();

    // Read the ACK.
    printf("Read the ACK.\n");
    ret_buffer[0] = 0;
    ack = ret_buffer[0];
    printf("before read. ack=%x\n",ack);
    ret = ftdi_read_data(ftdi, ret_buffer, 100);
    if (ret > 0) {
        ack = ret_buffer[0];
        printf("Read ACK. ret=%d, ack=%x\n",ret,ack);
    } else {
        printf("ERROR Read ACK. ret=%d, ack=%x\n",ret,ack);
    }
    // XXX printf("press Enter\n");
    // XXX getchar();


// XXX GOOD TO HERE

    // Send the command to read match data, 0x03.
    printf("\nSent command to read match data, 0x03.\n");
    ret = ftdi_write_data(ftdi, "\x03", 1); // cmd
    if (ret != 1)
    {
        printf("Error during ftdi_write_data: %d != %d\n",ret,1);
    }
    // XXX printf("press Enter\n");
    // XXX getchar();

    // Read the match data
    printf("Read the match data.\n");
    ret = ftdi_read_data(ftdi, ret_buffer, 100);
    if (ret > 0) {
        printf("Num of bytes read=%d\n",ret);
        for (int i=0; i<ret; i++)
        {
            printf("%d: %x %c\n",i,ret_buffer[i],ret_buffer[i]);
        }
    } else {
        printf("ERROR ret=%d\n",ret);
    }
    // XXX printf("press Enter\n");
    // XXX getchar();


    // Close connections
    printf("Close the ftdi_usb.\n");
    ret = ftdi_usb_close(ftdi);
    if (ret < 0)
    {
        printf("unable to close ftdi: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
    }

    return EXIT_SUCCESS;
}


