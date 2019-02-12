/*
 * FILE : ifind.c
 *
 * Interactive Find.
 *
 * This program loads the dataset into memory.
 * It provides an interactive prompt for
 * entering MD5 hashes, string lengths, and
 * starting a search of the gutenberg library for a string
 * that has the same MD5 hash.
 *
 * It designed to run on a RPI connected to an FPGA
 * board using a 16-bit GPIO bus.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 01/11/2019
 */

#include "find_lib.h"
#include "kbinput.h"

void menu(char *md5_hash)
{
    printf("\nMenu\n");
    printf("   1. Change hash: %s\n",md5_hash);
    printf("   2. Change string length\n");
    printf("   3. Start Search\n");
    printf("   4. Menu (also Enter Key)\n");
    printf("   5. Quit\n");
}


int main(int argc, char *argv[])
{
    int ok,ret;
    int done;
    struct manifest_info minfo;
    char md5_hash[33] = {
        48,48,48,48,48,48,48,48,
        48,48,48,48,48,48,48,48,
        48,48,48,48,48,48,48,48,
        48,48,48,48,48,48,48,48,0
    };
    char in_md5_hash[33];
    unsigned char target_hash[16] = {0};
    unsigned char in_target_hash[16] = {0};

    // Parse the manifest.txt file
    printf("Parsing manifiest ... \n");
    ok = parse_manifest("manifest.txt", &minfo);
    if (!ok)
    {
        printf("ERROR: parse_manifest did not return cleanly.\n");
    }
    printf("Done\n");
    printf("num_files: %d\n",minfo.num_files);
    printf("total_size: %ld\n",minfo.total_size);

    // Display a menu
    done = 0;
    menu(md5_hash);
    while(!done)
    {
        // Was a keyboard button pressed?
        switch(kbinput_read())
        {
            case '1' :
                printf("\nEnter Hash: \n");
                ret = scanf("%s",in_md5_hash);
                if (ret == EOF)
                {
                    printf("ERROR scanf returned EOF\n");
                    break;
                }
                if (convert_hash(in_md5_hash, in_target_hash))
                {
                    strcpy(md5_hash,in_md5_hash);
                    printf("md5_hash_bytes: ");
                    for (int i=0; i<16; i++)
                    {
                        target_hash[i] = in_target_hash[i];
                        printf("%.2x ",target_hash[i]);
                    }
                    printf("\n");
                }
                break;
            case '2' :
                printf("\nEnter String Length: \n");
                break;
            case '3' :
                printf("\nStarting Search...\n");
                break;
            case '\n' :
                menu(md5_hash); 
                break;
            case '4' :
                menu(md5_hash); 
                break;
            case '5' :
                printf("\nQuit. Bye.\n");
                done = 1;
                break;
            default :
                break;
        }
    }

    free(minfo.book);
    return EXIT_SUCCESS;
}

