/*
 * FILE : sdcard.c
 *
 * Generate a data.txt of the whole dataset that
 * can be written to an sdcard.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 02/22/2019
 */


#include "find_lib.h"

int main(int argc, char *argv[])
{
    int ok; 
    struct manifest_info minfo;
    unsigned char *block_text=NULL;
    FILE *fp;
    size_t nwrite;

    // Parse the manifest.txt file
    printf("Parsing manifiest ... \n");
    ok = parse_manifest("manifest.txt", &minfo);
    if (!ok)
    {
        printf("ERROR: parse_manifest did not return cleanly.\n");
        return -1;
    }
    printf("Done\n");
    printf("num_files: %d\n",minfo.num_files);
    printf("total_size: %ld\n",minfo.total_size);

    // Load the books into memory
    block_text = load_books(&minfo);
    if (block_text == NULL)
    {
        printf("ERROR: load_books did not return cleanly.\n");
    }

    // Write block_text to a file
    fp = fopen("data.txt","wb");

    nwrite = fwrite(block_text, sizeof(char), minfo.total_size, fp);

    if (nwrite != minfo.total_size)
    {
        printf("ERROR: nwrite: %ld, total_size: %ld\n",nwrite,minfo.total_size);
    }

    fclose(fp);

    printf("Done.\n");

    return 0;

}


