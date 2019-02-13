/*
 * FILE : munchman16.h
 *
 * Library of functions for the Munchman project.
 * Talks to the 16-bit parallel bus.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 11/04/2018
 *
 * Updates:
 * 01/25/2019 : Updates for new parallel bus
 * 02/10/2019 : Updated for the 16-bit parallel bus.
 */

#ifndef _MUNCHMAN_H_
#define _MUNCHMAN_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <errno.h>

/*
***************************
* Constants
***************************
*/
#define BUFFER_SIZE 65000
#define BUS_WIDTH   16

// Parallel Bus GPIOs
#define DATA0    (21)
#define DATA1    (20)
#define DATA2    (16)
#define DATA3    (12)
#define DATA4    (25)
#define DATA5    (24)
#define DATA6    (23)
#define DATA7    (18)
#define DATA8    (5)
#define DATA9    (11)
#define DATA10   (9)
#define DATA11   (10)
#define DATA12   (22)
#define DATA13   (27)
#define DATA14   (17)
#define DATA15   (4)
#define RNW      (26)
#define CLK      (19)
#define DONE     (13)
#define MATCH    (6)

/*
***************************
* Structures
***************************
*/

struct match_result
{
    int pos;
    unsigned char str[56];
};

/*
***************************
* Variables
***************************
*/
extern unsigned char ret_buffer[];

extern unsigned int set_reg;
extern unsigned int clr_reg;

extern unsigned int read_pins;
extern unsigned char read_val;

extern int STR_LEN;

/*
***************************
* Functions
***************************
*/

void sleep_ms(int ms);
void sleep_us(int us);
void sync_bus();
unsigned char wait_bus_done();
void bus_write_config();
void bus_read_config();
void bus_write16(unsigned char msb, unsigned char lsb);
unsigned char bus_read();
int bus_read_data(unsigned char *buffer, int num_to_read);
int bus_write_data16(unsigned char *buffer, int num_to_write);

void cmd_test();
char cmd_set_hash(unsigned char *target_hash);
char cmd_send_text(unsigned char *text_str, int text_str_len);
char cmd_read_match(struct match_result *result);
char cmd_str_len(unsigned char num_chars);
char cmd_close();

unsigned char send_file(char *filename, struct match_result *match, int lflag,
        unsigned char *target_hash, int *num_hashes);

char send_block(unsigned char *block_text, unsigned long block_text_len);

#ifdef __cplusplus
}
#endif

#endif

