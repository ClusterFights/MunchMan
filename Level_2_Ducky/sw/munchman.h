/*
 * FILE : munchman.h
 *
 * Library of functions for the Munchman project.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 11/04/2018
 */

#ifndef _MUNCHMAN_H_
#define _MUNCHMAN_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <stdlib.h>
#include <ftdi.h>
#include <time.h>
#include <sys/time.h>
#include <errno.h>

int ftdi_setup(struct ftdi_context *ftdi);
int filecopy(FILE *ifp, struct ftdi_context *ftdi);


#ifdef __cplusplus
}
#endif

#endif

