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
 * returns: 1 for success, or -1 for fail.
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
        return -1;
    }

    while ((read = getline (&line, &len, fp)) != -1 ) {
        if (line_num >1) 
        {
            // Parse line
            sscanf(line, "%d %s",&byte_count, str);
            minfo->book[line_num-2].size = byte_count;
            strcpy(minfo->book[line_num-2].file_path,str);

            printf("%d, line length %d, %s\n",(line_num-2),minfo->book[line_num-2].size,minfo->book[line_num-2].file_path);

        } else if (line_num == 1)
        {
            // Parse num of files
            sscanf(line, "%s %d",str, &num_files);
            minfo->num_files = num_files;
            printf("num_files: %d \n",minfo->num_files);

            // malloc space for the array of book_info
            minfo->book = malloc(num_files*sizeof(struct book_info));
            
            if (minfo->book == NULL)
            {
                printf("ERROR: Could not malloc space for book_info.\n");
                return -1;
            }
        } else if (line_num == 0)
        {
            // Parse total_size of dataset
            sscanf(line, "%s %d",str, &total_size);
            minfo->total_size = total_size;
            printf("total_size: %ld \n",minfo->total_size);
        }
        line_num++;
    }

    // Clean up
    fclose(fp);
    free(line);

    return 1;
}

/*
 * Loads books into ram
 */
/*
void load_books()
{
    FILE *fp;
    size_t nread;
    unsigned char *block_text_start;
    block_text = malloc(426138189*sizeof(unsigned char));
    block_text_start = block_text;
    if (block_text)
    {
        printf("Yay! block_text malloc'd OK!\n");
        printf("Loading books...\n");
        // Load the books
        for (int i=0; i<num_of_books; i++)
        {
            printf("%d: %s\n",i,manifest_list[i].file_path);
            fp = fopen(manifest_list[i].file_path,"rb");
            if (fp == NULL) {
                printf("  ERROR: send_file can't open %s\n", manifest_list[i].file_path);
                continue;
            }
            nread = fread(block_text, sizeof(char), manifest_list[i].size, fp);
            if (nread != manifest_list[i].size)
            {
                printf("  ERROR: nread(%ld) != size(%d)\n", nread,manifest_list[i].size);
            }
            block_text += nread;
            fclose(fp);
        }
        block_text = block_text_start;
        printf("DONE loading books.\n");
    } else
    {
        printf("Bummer! block_text malloc failed!\n");
    }
}
*/


