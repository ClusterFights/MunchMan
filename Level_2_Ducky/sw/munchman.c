/*
 * FILE : munchman.c
 *
 * Library of functions for the Munchman project.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 11/04/2018
 */

#include "munchman.h"
#include "md5.h"
#include <string.h>

// Size of string to hash. 19 char + 1 `\0`
#define STR_LEN 20

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
 * Helper functions that changes chars
 * like newline into `\n` so match
 * string can be printed on one line.
 */
void to_byte_str(char *src, char *dst)
{
    int i,j;

    dst[0] = 'b';
    dst[1] = 0x27;  // '

    for (i=0,j=2; i<strlen(src); i++)
    {
        if (src[i] == '\n')
        {
            dst[j++] = '\\';
            dst[j++] = 'n';
        } else if (src[i] == '\r')
        {
            dst[j++] = '\\';
            dst[j++] = 'r';
        } else
        {
            dst[j++] = src[i];
        }
    }
    dst[j++] = 0x27;  // '
    dst[j++] = '\0';
}

/*
 * Helper functions to push character into
 * fixed length buffer
 */
void string_push(unsigned char *buffer, unsigned char ch)
{
    for (int i=0; i<(STR_LEN-2); i++)
    {
        buffer[i] = buffer[i+1];
    }
    buffer[STR_LEN-2] = ch;
    // NOTE: last char buffer[STR_LEN-1] is '\0'
    //
}


/*
 * Sends a file block by block to the FPGA to
 * search for md5_match.
 */
int send_file(char *filename, struct ftdi_context *ftdi, 
        struct match_result *match, int lflag,
        unsigned char *target_hash)
{
    char buffer[BUFFER_SIZE];
    size_t nread;
    int ack=0;
    FILE *fp;
    int loop=0;
    int byte_offset=0;
    char match_str[50];
    char buffer_hash[STR_LEN] = {0};
    int bhi = 0;    // buffer_hash_index
    int num_hashes = 0;
    unsigned char hash_str[16];

    // Reset the match position to zero.
    match->pos = 0;

    // Open filehandle
    fp = fopen(filename,"rb");
    if (fp == NULL) {
        printf("ERROR: send_file can't open %s\n", filename);
        return -1;
    }

    while (nread = fread(buffer, sizeof(char), sizeof(buffer), fp), nread > 0)
    {

        if (lflag == 0)
        {
            // Process on FPGA board
            ack = cmd_send_text(ftdi, buffer, nread);
            if (ack == 1)
            {
                printf("FOUND! md5_hash found.\n");

                printf("\nSent command to read match data, 0x03.\n");
                cmd_read_match(ftdi, match);
                byte_offset = (loop*BUFFER_SIZE) + match->pos - 18;
                to_byte_str(match->str,match_str);
                printf("byte_offset = %d \n",byte_offset);
                printf("match_str = %s \n",match_str);

                fclose(fp);
                return 1;
            } else if (ack == -1)
            {
                printf("ERROR: during send_file cmd_send_text ftdi\n");
                fclose(fp);
                return -1;
            }
        } 
        else
        {
            // Process locally.
            for (int i=0; i<nread; i++)
            {
                if (bhi < (STR_LEN-1))
                {
                    // buffer not full yet.
                    buffer_hash[bhi++] = buffer[i];
                } 
                else
                {
                    // buffer_hash is full, so calc MD5 hash
                    num_hashes++;
                    md5(buffer_hash, hash_str);
                    if ( (hash_str[0] == target_hash[0]) && (hash_str[1] == target_hash[1]) &&
                         (hash_str[2] == target_hash[2]) && (hash_str[3] == target_hash[3]) &&
                         (hash_str[4] == target_hash[4]) && (hash_str[5] == target_hash[5]) &&
                         (hash_str[6] == target_hash[6]) && (hash_str[7] == target_hash[7]) &&
                         (hash_str[8] == target_hash[8]) && (hash_str[9] == target_hash[9]) &&
                         (hash_str[10] == target_hash[10]) && (hash_str[11] == target_hash[11]) &&
                         (hash_str[12] == target_hash[12]) && (hash_str[13] == target_hash[13]) &&
                         (hash_str[14] == target_hash[14]) && (hash_str[15] == target_hash[15])
                       )
                    {
                        // It's a match!
                        match->pos = i;
                        strcpy(match->str,buffer_hash);
                        byte_offset = (loop*BUFFER_SIZE) + match->pos - 19;
                        to_byte_str(match->str,match_str);
                        printf("num_hashes = %d \n",num_hashes);
                        printf("byte_offset = %d \n",byte_offset);
                        printf("match_str = %s \n",match_str);
                        fclose(fp);
                        return 1;
                    }

                    // buffer is full, so drop oldest char
                    // TODO: on Last buffer of the file need to
                    // process this last hash.
                    string_push(buffer_hash,buffer[i]);
                }
            }
        }
        loop++;
    }

    fclose(fp);
    return 0;
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
        printf("ERROR cmd_send_text during send text: %d != %d\n",ret,text_str_len);
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


