/*
 * FILE : find.c
 *
 * This program takes a MD5 hash and searches
 * the gutenberg library for a 19 character string
 * that has the same MD5 hash.
 *
 * It uses an FPGA board that is connected via
 * an FTDI serial link to accelerate the processing
 * of strings into MD5 hashes to find the match.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 11/12/2018
 */

#include "munchman.h"
#include <string.h>
#include <errno.h>
#include <stdlib.h>

static char USEAGE[] = "Usage: find md5_hash\n";

static unsigned char target_hash[16] = {0};

int main(int argc, char *argv[])
{
    char *md5_hash_arg;
    int num;

    if (argc != 2) {    // wrong number of args; print usage
        printf("%s",USEAGE);
        return EXIT_FAILURE;
    }

    // Verify md5_hash argument
    md5_hash_arg = argv[1];
    printf("md5_hash: %s\n",md5_hash_arg);

    // Check that md5_hash is 16 bytes or 32 chars.
    if (strlen(md5_hash_arg) != 32) {
        printf("ERROR: md5_hash must be 16 bytes or 32 hex chars.\n");
        printf("%s",USEAGE);
        return EXIT_FAILURE;
    }

    // Convert md5_hash_arg hex string to target_hash byte array.
    char tmp_str[2];
    for (int i=0,j=0; i<32; i+=2,j++)
    {
        tmp_str[0] = md5_hash_arg[i];
        tmp_str[1] = md5_hash_arg[i+1];
        target_hash[j] = (unsigned char)strtol(tmp_str,NULL,16);
        printf("target_hash[%d]: %x \n",j,target_hash[j]);
    }



    return EXIT_SUCCESS;
}

