
/*
 * FILE : find_lib.h
 *
 * Library of functions for the "find" command.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 02/11/2019
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
#include <limits.h>
#include <string.h>


/*
***************************
* Constants
***************************
*/


/*
***************************
* Structures
***************************
*/


struct book_info
{
    unsigned int size;
    char file_path[100];
};

struct manifest_info
{
    unsigned long total_size;
    unsigned int num_files;
    struct book_info *book;
};


/*
***************************
* Functions
***************************
*/

int parse_manifest(char *mfile, struct manifest_info *minfo);

#ifdef __cplusplus
}
#endif

#endif

