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

#include "munchman16.h"
#include "find_lib.h"
#include "kbinput.h"

void menu(char *md5_hash, int str_len)
{
    printf("\nMenu\n");
    printf("   1. Change hash: %s\n",md5_hash);
    printf("   2. Change string length: %d\n",str_len);
    printf("   3. Resync the bus\n");
    printf("   4. Start Search\n");
    printf("   5. Menu (also Enter Key)\n");
    printf("   6. Quit\n");
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
    unsigned char *block_text=NULL;
    int str_len = 19;
    int in_str_len = 19;

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

    // Load the books into memory
    ok = load_books(&minfo, block_text);
    if (!ok)
    {
        printf("ERROR: load_books did not return cleanly.\n");
    }

    // Sync the bus
    sync_bus();
    printf("The 16-bit bus is synced.\n");

    // Display a menu
    done = 0;
    menu(md5_hash, str_len);
    while(!done)
    {
        // Was a keyboard button pressed?
        switch(kbinput_read())
        {
            case '1' : // Change Hash
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
                    // Send new target_hash to board
                    ret = cmd_set_hash(target_hash);
                    if (ret != 1)
                    {
                        printf("ERROR: cmd_set_hash() failed.\n");
                    }
                } else
                {
                    printf("ERROR: convert_hash() failed.\n");
                }
                break;
            case '2' : // Change String Length
                printf("\nEnter String Length: \n");
                ret = scanf("%d",&in_str_len);
                if (ret == EOF)
                {
                    printf("ERROR scanf returned EOF\n");
                    break;
                }
                str_len = in_str_len;
                // Sent new str_len to board
                ret = cmd_str_len(str_len);
                if (ret != 1)
                {
                    printf("ERROR: cmd_str_len() failed.\n");
                }
                break;
            case '3' : // Resync the bus
                cmd_close();
                printf("\nClosed the bus...\n");
                sync_bus();
                printf("Resynced the bus\n");
                break;
            case '4' : // Begin Search
                printf("\nStarting Search...\n");
                ret = send_block(block_text, minfo.total_size);
                if (ret != 1)
                {
                    printf("ERROR: string search failed.\n");
                }
                break;
            case '\n' : // Print Menu
                menu(md5_hash, str_len);
                break;
            case '5' : // Print Menu
                menu(md5_hash, str_len);
                break;
            case '6' : // Quit
                printf("\nQuit. Bye.\n");
                done = 1;
                break;
            default :
                break;
        }
    }

    free(minfo.book);
    free(block_text);

    // Desync the bus
    cmd_close();

    return EXIT_SUCCESS;
}

