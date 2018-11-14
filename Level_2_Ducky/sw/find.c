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
#include <limits.h>
#include <stdlib.h>

#define MAX_BOOKS 600

struct manifest_info
{
    int size;
    char file_path[100];
};

static char USEAGE[] = "Usage: find md5_hash\n";
static char *manifest_file = "manifest.txt";
static unsigned char target_hash[16] = {0};
static struct manifest_info manifest_list[MAX_BOOKS] = {0};
static int num_of_books = 0;
static struct ftdi_context *ftdi;

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
        if (line_num >1) 
        {
            // Parse line
            sscanf(line, "%d %s",&byte_count, str);
            manifest_list[line_num-2].size = byte_count;
            strcpy(manifest_list[line_num-2].file_path,str);
            // XXX printf("%d, line length %d, %s\n",(line_num-2),manifest_list[line_num-2].size,manifest_list[line_num-2].file_path);
        } else if (line_num == 1)
        {
            // Parse num of files
            sscanf(line, "%s %d",str, &num_of_books);
            // XXX printf("num_of_books: %d\n",num_of_books);
            if (num_of_books > MAX_BOOKS)
            {
                printf("ERROR: too many books. num_of_books=%d, MAX_BOOKS=%d\n",num_of_books,MAX_BOOKS);
                return -1;
            }
        }
        line_num++;
    }

    // Clean up
    fclose(fp);
    free(line);

    return 0;
}

/*
 * Search the dataset for md5_hash
 */
int run()
{
    // loop through all the books
    for (int i=0; i<num_of_books; i++)
    {
        // XXX printf("%i %s\n",i,manifest_list[i].file_path);
    }

    return 0;
}


int main(int argc, char *argv[])
{
    char md5_hash_arg[32];
    int num;
    int ret;

    if (argc != 2) {    // wrong number of args; print usage
        printf("%s",USEAGE);
        return EXIT_FAILURE;
    }

    // Check that md5_hash is 16 bytes or 32 chars.
    if (strlen(argv[1]) != 32) {
        printf("ERROR: md5_hash must be 16 bytes or 32 hex chars.\n");
        printf("%s",USEAGE);
        return EXIT_FAILURE;
    }

    // Copy and display md5_hash argument
    strcpy(md5_hash_arg,argv[1]);
    printf("md5_hash: %s\n",md5_hash_arg);

    // Convert md5_hash_arg hex string to target_hash byte array.
    char tmp_str[2];
    printf("md5_hash_bytes: ");
    for (int i=0,j=0; i<32; i+=2,j++)
    {
        tmp_str[0] = md5_hash_arg[i];
        tmp_str[1] = md5_hash_arg[i+1];
        errno = 0;      // reset errno before strtol call
        target_hash[j] = (unsigned char)strtol(tmp_str,NULL,16);
        if (errno != 0)
        {
            printf("ERROR: with md5_hash during strtol\n");
            return EXIT_FAILURE;
        }
        printf("%.2x ",target_hash[j]);
    }
    printf("\n");

    // Parse the manifest.txt file
    parse_manifest(manifest_file);

    // Setup the FTDI connections
    printf("Setup ftdi\n");
    if ((ftdi = ftdi_new()) == 0)
    {
        printf("ftdi_new failed\n");
        return EXIT_FAILURE;
    }

    // Initialize the ftdi.
    printf("Initialize ftdi\n");
    if (ftdi_setup(ftdi) < 0)
    {
        printf("ERROR: ftdi_setup failed.\n");
        return EXIT_FAILURE;
    }

    // Read anything that is hanging around.
    printf("Clear input char queue.\n");
    clear_ftdi(ftdi);

    // Send the set hash command 0x01.
    printf("Sending the set hash command 0x01.\n");
    cmd_set_hash(ftdi, target_hash);

    // Run the search
    run();

    // Close connections
    printf("Close the ftdi_usb.\n");
    ret = ftdi_usb_close(ftdi);
    if (ret < 0)
    {
        printf("unable to close ftdi: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
    }

    return EXIT_SUCCESS;
}

