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
    printf("   1. (M)enu (also Enter Key)\n");
    printf("   2. (H)ash: %s\n",md5_hash);
    printf("   3. (L)ength: %d\n",str_len);
    printf("   4. (R)esync bus\n");
    printf("   5. (S)tart Search\n");
    printf("   6. (Q)uit\n");
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
    block_text = load_books(&minfo);
    if (block_text == NULL)
    {
        printf("ERROR: load_books did not return cleanly.\n");
    }

    // Init and sync bus
    printf("Sync the bus.\n");
    bus_write_config();
    sleep_ms(100);
    sync_bus();
    sleep_ms(100);
    printf("The 16-bit bus is synced.\n");


    // Display a menu
    done = 0;
    menu(md5_hash, str_len);
    while(!done)
    {
        // Was a keyboard button pressed?
        switch(kbinput_read())
        {
            case '\n' : // Print Menu
            case 'm' : // Print Menu
            case 'M' : // Print Menu
            case '1' : // Print Menu
                menu(md5_hash, str_len);
                break;
            case 'h' : // Change Hash
            case 'H' : // Change Hash
            case '2' : // Change Hash
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
            case 'L' : // Change String Length
            case 'l' : // Change String Length
            case '3' : // Change String Length
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
            case 'r' : // Resync the bus
            case 'R' : // Resync the bus
            case '4' : // Resync the bus
                bus_write_config();
                /*
                sleep_ms(100);
                cmd_close();
                sleep_ms(100);
                printf("\nClosed the bus...\n");
                */
                sleep_ms(100);
                sync_bus();
                sleep_ms(100);
                printf("Resynced the bus\n");
                break;
            case 's' : // Begin Search
            case 'S' : // Begin Search
            case '5' : // Begin Search
                printf("\nStarting Search...\n");
                ret = send_block(block_text, minfo.total_size, str_len);
                if (ret == 0)
                {
                    printf("ERROR: string search failed.\n");
                } 
                break;
            case 'Q' : // Quit
            case 'q' : // Quit
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

