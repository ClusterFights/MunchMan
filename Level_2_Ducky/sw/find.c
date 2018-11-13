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

struct manifest_info
{
    int size;
    char file_path[100];
};

static char USEAGE[] = "Usage: find md5_hash\n";
static char *manifest_file = "manifest.txt";
static unsigned char target_hash[16] = {0};
static struct manifest_info manifest_list[600] = {0};

/*
 * Parses the manifest file.
 */
int parse_manifest(char *mfile)
{
    FILE *fp;
    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    int line_num = 0;
    int byte_count=0;
    char str[100];

    // Open filehandle to manifest file, mfile
    fp = fopen(mfile, "r");
    if (fp == NULL) {
        printf("ERROR parse_manifest: can't open %s\n", mfile);
        return -1;
    }

    while ((read = getline (&line, &len, fp)) != -1 ) {
        if (line_num >1) {
            // Parse line
            sscanf(line, "%d %s",&byte_count, str);
            manifest_list[line_num-2].size = byte_count;
            strcpy(manifest_list[line_num-2].file_path,str);
            // XXX printf("%d, line length %d, %s\n",(line_num-2),manifest_list[line_num-2].size,manifest_list[line_num-2].file_path);
        } 
        line_num++;
    }

    // Clean up
    fclose(fp);
    free(line);

    return 0;
}


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

    // Parse the manifest.txt file
    parse_manifest(manifest_file);


    return EXIT_SUCCESS;
}

