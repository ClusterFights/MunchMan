/*
 * FILE : ice_cat.c
 *
 * This program sends a file to the iCE40-HK8K board
 * over the FTDI usb link.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 10/13/2018
 */

#include "munchman.h"


int main(int argc, char *argv[])
{
    int ret, num;
    struct ftdi_context *ftdi;
    struct ftdi_version_info version;
    FILE *fp;

    if (argc == 1) {    // no args; print usage
        printf("Usage: ice_cat <file_to_send.txt>\n");
        return EXIT_FAILURE;
    }

    // Setup the FTDI connections
    printf("Setup ftdi\n");
    if ((ftdi = ftdi_new()) == 0)
    {
        printf("ftdi_new failed\n");
        return EXIT_FAILURE;
    }
    version = ftdi_get_library_version();
    printf("Initialized libftdi %s (major: %d, minor: %d, micro: %d, snapshot version : %s)\n",
            version.version_str, version.major, version.minor, version.micro,
            version.snapshot_str);
    printf("Created new ftdi\n");

    ftdi_setup(ftdi);
    printf("ftdi initialized\n");


    // Open filehandle to <file_to_send.txt>
    fp = fopen(*++argv, "r");
    if (fp == NULL) {
        printf("can't open %s\n", *argv);
        return EXIT_FAILURE;
    }
    printf("openned file: %s\n", *argv);

    // Copy file to FTDI connection
    struct timeval tv1, tv2;
    gettimeofday(&tv1, NULL);
    num = filecopy(fp, ftdi);
    gettimeofday(&tv2, NULL);
    printf("bytes: %d\n",num);
    double total_time = (double) (tv2.tv_usec - tv1.tv_usec) / 1000000 +
         (double) (tv2.tv_sec - tv1.tv_sec);
    printf ("Total time = %f seconds\n", total_time);
    double bytes_per_sec = num / total_time;
    printf("bytes_per_sec: %f\n",bytes_per_sec);

    // Close connections
    fclose(fp);
    ret = ftdi_usb_close(ftdi);
    if (ret < 0)
    {
        printf("unable to close ftdi: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
    }


    ftdi_free(ftdi);
    return EXIT_SUCCESS;
}

