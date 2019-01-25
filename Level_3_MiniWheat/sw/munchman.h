/*
 * FILE : munchman.h
 *
 * Library of functions for the Munchman project.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 11/04/2018
 */

#ifndef _MUNCHMAN_H_
#define _MUNCHMAN_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <stdlib.h>
// XXX #include <ftdi.h>
#include <time.h>
#include <sys/time.h>
#include <errno.h>

/*
***************************
* Constants
***************************
*/
#define BUFFER_SIZE 200

/*
***************************
* Structures
***************************
*/

struct match_result
{
    int pos;
    unsigned char str[19];
};



/*
***************************
* Functions
***************************
*/
// XXX int ftdi_setup(struct ftdi_context *ftdi);
// XXX void clear_ftdi(struct ftdi_context *ftdi);
int filecopy(FILE *ifp, struct ftdi_context *ftdi);
void cmd_test(struct ftdi_context *ftdi);
int cmd_set_hash(struct ftdi_context *ftdi, unsigned char *target_hash);
int cmd_send_text(struct ftdi_context *ftdi, unsigned char *text_str,
        int text_str_len);
int cmd_read_match(struct ftdi_context *ftdi, struct match_result *result);
int send_file(char *filename, struct ftdi_context *ftdi, 
        struct match_result *match, int lflag,
        unsigned char *target_hash, int *num_hashes);
void sleep_us(int us);


/*
***************************
* Variables
***************************
*/
extern unsigned char ret_buffer[];

#ifdef __cplusplus
}
#endif

#endif

