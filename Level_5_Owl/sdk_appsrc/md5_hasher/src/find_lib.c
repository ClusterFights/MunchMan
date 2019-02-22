/*
 * FILE : find_lib.c
 *
 * Library of functions for the Munchman project.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 02/11/2019
 */

#include "find_lib.h"


/*
***************************
* Functions
***************************
*/

/*
 * Parses the manifest file.
 * mfile : The manifest to parse
 * minfo:  A structure that has the parsed manifiest info.
 * returns: 1 for success, or 0 for fail.
 *
 * Remember to free(minfo->book).
 *
 */
int parse_manifest(char *mfile, struct manifest_info *minfo)
{
    FILE *fp;
    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    int line_num = 0;
    int byte_count=0;
    char str[100];
    unsigned int total_size;
    unsigned int num_files;

    // Open filehandle to manifest file, mfile
    fp = fopen(mfile, "r");
    if (fp == NULL) {
        printf("ERROR parse_manifest: can't open %s\n", mfile);
        return 0;
    }

    while ((read = getline (&line, &len, fp)) != -1 ) {
        if (line_num >1) 
        {
            // Parse line
            sscanf(line, "%d %s",&byte_count, str);
            minfo->book[line_num-2].size = byte_count;
            strcpy(minfo->book[line_num-2].file_path,str);

            // XXX printf("%d, line length %d, %s\n",(line_num-2),minfo->book[line_num-2].size,minfo->book[line_num-2].file_path);

        } else if (line_num == 1)
        {
            // Parse num of files
            sscanf(line, "%s %d",str, &num_files);
            minfo->num_files = num_files;
            // XXX printf("num_files: %d \n",minfo->num_files);

            // malloc space for the array of book_info
            minfo->book = malloc(num_files*sizeof(struct book_info));
            
            if (minfo->book == NULL)
            {
                printf("ERROR: Could not malloc space for book_info.\n");
                return 0;
            }
        } else if (line_num == 0)
        {
            // Parse total_size of dataset
            sscanf(line, "%s %d",str, &total_size);
            minfo->total_size = total_size;
            // XXX printf("total_size: %ld \n",minfo->total_size);
        }
        line_num++;
    }

    // Clean up
    fclose(fp);
    free(line);

    return 1;
}

/*
 * Convert a 32 char ascii hex string (md5_hash) into
 * a 16 byte binary hash.
 * Returns : 1 for success, 0 for failure.
 */
int convert_hash(char *md5_hash, unsigned char *target_hash)
{
    // Check that md5_hash is 16 bytes or 32 chars.
    if (strlen(md5_hash) != 32) {
        printf("ERROR: md5_hash must be 16 bytes or 32 hex chars.\n");
        return 0;
    }

    // Convert md5_hash hex string to target_hash byte array.
    char tmp_str[2] ="00";
    // XXX printf("md5_hash_bytes: ");
    for (int i=0, j=0; i<32; i+=2,j++)
    {
        tmp_str[0] = md5_hash[i];
        tmp_str[1] = md5_hash[i+1];
        // XXX printf("%d %x \n",i,md5_hash[i]);
        // XXX printf("%d %x \n",i+1,md5_hash[i+1]);
        errno = 0;      // reset errno before strtol call
        target_hash[j] = (unsigned char)strtol(tmp_str,NULL,16);
        if (errno != 0)
        {
            printf("ERROR: with md5_hash during strtol\n");
            return 0;
        }
        // XXX printf("%.2x ",target_hash[j]);
    }
    // XXX printf("\n");
    return 1;
}

/*
 * Compute elapsed time in seconds.
 */
double elapsed_time(struct timeval *tv1, struct timeval *tv2)
{
    return (double) (tv2->tv_usec - tv1->tv_usec) / 1000000 +
         (double) (tv2->tv_sec - tv1->tv_sec);
}

/*
 * Loads books into ram.
 * Returns : Pointer to allocated memory.
 *
 * Don't forget to free block_text
 */
unsigned char* load_books(struct manifest_info *minfo)
{
    FILE *fp;
    size_t nread;
    unsigned char *block_text_ptr=NULL;
    // XXX int ret=1;
    struct timeval tv1, tv2;
    double total_time;
    unsigned char *block_text=NULL;


    block_text = malloc(minfo->total_size*sizeof(unsigned char));
    block_text_ptr = block_text;
    if (block_text_ptr)
    {
        // XXX printf("Yay! block_text malloc'd OK!\n");
        printf("Loading books...\n");

        // Start the timer.
        gettimeofday(&tv1, NULL);

        // Load the books
        for (int i=0; i<minfo->num_files; i++)
        {
            // XXX printf("%d: %s\n",i,minfo->book[i].file_path);
            fp = fopen(minfo->book[i].file_path,"rb");
            if (fp == NULL) {
                printf("  ERROR: send_file can't open %s\n", minfo->book[i].file_path);
                // XXX ret = 0;
                continue;
            }
            nread = fread(block_text_ptr, sizeof(char), minfo->book[i].size, fp);
            if (nread != minfo->book[i].size)
            {
                printf("  ERROR: nread(%d) != size(%d)\n", nread,minfo->book[i].size);
                // XXX ret = 0;
            }
            block_text_ptr += nread;
            fclose(fp);
        }

        // Stop the timer
        gettimeofday(&tv2, NULL);
        total_time = elapsed_time(&tv1, &tv2);
        printf("DONE loading books.\n");
        printf ("Total time = %f seconds\n", total_time);
    } else
    {
        printf("ERROR: Bummer! block_text malloc failed!\n");
        // XXX ret = 0;
    }
    return block_text;
}


