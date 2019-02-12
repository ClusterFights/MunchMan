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


int main(int argc, char *argv[])
{
    int ok;
    int done;
    struct manifest_info minfo;

    // Parse the manifest.txt file
    ok = parse_manifest("manifest.txt", &minfo);
    if (!ok)
    {
        printf("ERROR: parse_manifest did not return cleanly.\n");
    }

    // Display a menu
    done = 0;
    printf("> ");
    while(!done)
    {
        // Was a keyboard button pressed?
        switch(kbinput_read())
        {
            case 'h' :
                printf("enter hash: \n");
                break;
            case 's' :
                printf("enter string length: \n");
                break;
            case 'g' :
                printf("go find the string: \n");
                break;
            case 'q' :
                printf("Quit. Bye.\n");
                done = 1;
                break;
            default :
                break;
        }
    }

    free(minfo.book);
    return EXIT_SUCCESS;
}

