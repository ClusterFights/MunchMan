/*
 * FILE : munchman.c
 *
 * Library of functions for the Munchman project.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 11/04/2018
 */

#include "munchman.h"
#include <string.h>

unsigned char ret_buffer[BUFFER_SIZE] = {0};

int ftdi_setup(struct ftdi_context *ftdi)
{
    int ret;

    // Set the interface to B which should be the uart.
    ftdi_set_interface(ftdi, INTERFACE_B);

    // Open the fpga ftdi connection
    if ((ret = ftdi_usb_open(ftdi, 0x0403, 0x6010)) < 0)
    {
        printf("unable to open ftdi device: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
        return -1;
    }

    // Set the BAUD rate
    if ((ret = ftdi_set_baudrate(ftdi, 12000000)) < 0)
    {
        printf("unable to set baudrate: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
        return -1;
    }
    return 0;
}

/*
 * Reads from the ftdi channel and sends the results
 * to the bit bucket.
 */
void clear_ftdi(struct ftdi_context *ftdi)
{
    int ret;
    ret = ftdi_read_data(ftdi, ret_buffer, BUFFER_SIZE);
    if (ret > 0) {
        printf("WARN, clear_ftdi read some data ret=%d\n",ret);
    }
}


int filecopy(FILE *ifp, struct ftdi_context *ftdi)
{
    char buffer[4096];
    char *out_ptr = buffer;
    size_t nread; 
    int nwritten;
    int num_sent = 0;

    while (nread = fread(buffer, sizeof(char), sizeof(buffer), ifp), nread > 0)
    {
        out_ptr = buffer;
        do
        {
            nwritten = ftdi_write_data(ftdi, out_ptr, nread);
            if (nwritten >= 0)
            {
                num_sent += nwritten;
                nread -= nwritten;
                out_ptr += nwritten;
            } 
            else
            {
                printf("Error during ftd_write_data: %d",nwritten);
                return -1;
            }
        } while (nread > 0);
    }

    return num_sent;
}


/*
 * Sends the test command 0x04 and prints
 * out the return bytes which should be
 * 10,9,8...1
 */
void cmd_test(struct ftdi_context *ftdi)
{
    int ret;

    ret = ftdi_write_data(ftdi, "\x04", 1); // cmd
    if (ret != 1)
    {
        printf("ERROR during cmd_test, ftdi_write_data: %d != %d\n",ret,1);
    }

    // Read the test bytes 10,9,8..1
    printf("Read the test bytes 10,9,8..1.\n");
    ret = ftdi_read_data(ftdi, ret_buffer, BUFFER_SIZE);
    if (ret > 0) {
        printf("Num of bytes read=%d\n",ret);
        for (int i=0; i<ret; i++)
        {
            printf("%d: %x\n",i,ret_buffer[i]);
        }
    } else {
        printf("ERROR cmd_test ret=%d\n",ret);
    }
}

/*
 * Reads the ACK.
 * 1 = ACK.
 * 0 = NACK.
 * -1 = ERROR.
 */
int read_ack(struct ftdi_context *ftdi)
{
    int ret;
    int ack = -1;

    ret_buffer[0] = -1;
    ret = ftdi_read_data(ftdi, ret_buffer, BUFFER_SIZE);
    if (ret > 0) {
        ack = ret_buffer[0];
    } else {
        printf("ERROR read_ack. ret=%d, ack=%x\n",ret,ack);
    }
    return ack;
}

/*
 * Sends the set hash cmd 0x01.
 * Return 1 for ACK, 0 for NACK, -1 for ERROR.
 */
int cmd_set_hash(struct ftdi_context *ftdi, unsigned char *target_hash)
{
    int ret;

    // Send the set hash command 0x01.
    ret = ftdi_write_data(ftdi, "\x01", 1); // cmd
    if (ret != 1)
    {
        printf("Error cmd_set_hash during cmd write: %d != %d\n",ret,1);
        return -1;
    }

    // Send the target hash.
    ret = ftdi_write_data(ftdi, target_hash, 16); //data
    if (ret != 16)
    {
        printf("ERROR cmd_set_hash during hash write: %d != %d\n",ret,16);
        return -1;
    }

    return read_ack(ftdi);
}

/*
 * Sends the send_text cmd, 0x02.
 * Return 1 for ACK, 0 for NACK, -1 for ERROR.
 *
 * ACK indicates that a string was found that matches
 * the target hash.
 */
int cmd_send_text(struct ftdi_context *ftdi, unsigned char *text_str,
        int text_str_len)
{
    int ret;
    unsigned char len_bytes[2];

    ret = ftdi_write_data(ftdi, "\x02", 1); // cmd
    if (ret != 1)
    {
        printf("ERROR cmd_send_text during write cmd: %d != %d\n",ret,1);
        return -1;
    }

    // Send the number of bytes to be sent.
    len_bytes[0] = (unsigned char)text_str_len>>8;
    len_bytes[1] = (unsigned char)(text_str_len & 0xFF);
    ret = ftdi_write_data(ftdi, len_bytes, 2);
    if (ret != 2)
    {
        printf("ERROR cmd_send during send length: %d != %d\n",ret,2);
        return -1;
    }

    // Send the string.
    ret = ftdi_write_data(ftdi, text_str, text_str_len);
    if (ret != text_str_len)
    {
        printf("ERROR cmd_sned during send text: %d != %d\n",ret,text_str_len);
        return -1;
    }

    // Read the ACK.
    return read_ack(ftdi);
}

/*
 * Sends the read match, 0x03.
 * Puts the result in match_result
 * Assumes that result has a str that has been allocated
 * Return 1 for success.
 */
int cmd_read_match(struct ftdi_context *ftdi, struct match_result *result)
{
    int ret;

    ret = ftdi_write_data(ftdi, "\x03", 1); // cmd
    if (ret != 1)
    {
        printf("ERROR cmd_read_match, during write cmd: %d != %d\n",ret,1);
        return -1;
    }

    // Read the match data
    ret = ftdi_read_data(ftdi, ret_buffer, BUFFER_SIZE);
    if (ret == 21) {
        result->pos = (int)((ret_buffer[0]<<8) + (ret_buffer[1]&0xFF));
        strncpy(result->str,&ret_buffer[2],19);
    } else {
        printf("ERROR cmd_read_match, wrong length of data ret=%d != 21\n",ret);
        return -1;
    }

    return 1; // success
}


