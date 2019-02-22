/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include "xparameters.h"
#include "platform.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "md5_hasher.h"
#include <stdio.h>
#include <stdlib.h>
#include "xaxidma.h"


#define DMA_DEV_ID		XPAR_AXIDMA_0_DEVICE_ID


// target md5 hash for "The quick brown fox"
static u32 target_hash[] = {
    0xa2004f37,
    0x730b9445,
    0x670a738f,
    0xa0fc9ee5
};

static unsigned char test_str[] = "HHello. The quick brown fox jumps over the lazy dog.";

void menu(char* md5_hash, int str_len)
{
	xil_printf("\n\r\n\rMenu\n\r");
	xil_printf("1 : (H)ash: %s \n\r",md5_hash);
	xil_printf("2 : (L)ength: %d  \n\r",str_len);
	xil_printf("3 : (S)tatus \n\r");
	xil_printf("4 : (R)un hasher \n\r");
	xil_printf("5 : (Q)uit\n\r");
}

int main()
{
    char c;
    int done=0;
    struct match_result match;
    char md5_hash[33] = {
        48,48,48,48,48,48,48,48,
        48,48,48,48,48,48,48,48,
        48,48,48,48,48,48,48,48,
        48,48,48,48,48,48,48,48,0
    };
    int str_len = 19;

    init_platform();

    // Init the md5_hasher and DMA engine
    cmd_reset(XPAR_MD5_HASHER_0_BASEADDR);
    dma_init(DMA_DEV_ID);
    cmd_enable(XPAR_MD5_HASHER_0_BASEADDR);


    while(!done)
    {
    	menu(md5_hash, str_len);
    	c=inbyte();
		printf("\n\rOption Selected : %c \n\r",c);

    	switch(c)
    	{
    		case 'H' :
    		case 'h' :
			case '1' :
				xil_printf("Loading target hash\n\r");
				MD5_HASHER_mWriteReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG2_HASH0, target_hash[0]);
				MD5_HASHER_mWriteReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG3_HASH1, target_hash[1]);
				MD5_HASHER_mWriteReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG4_HASH2, target_hash[2]);
				MD5_HASHER_mWriteReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG5_HASH3, target_hash[3]);

				xil_printf("Reading back the has values:\n\r");
				u32 th[4];
				th[0] =  MD5_HASHER_mReadReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG2_HASH0);
				th[1] =  MD5_HASHER_mReadReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG3_HASH1);
				th[2] =  MD5_HASHER_mReadReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG4_HASH2);
				th[3] =  MD5_HASHER_mReadReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG5_HASH3);

				xil_printf("th0 : %x \n\r",th[0]);
				xil_printf("th1 : %x \n\r",th[1]);
				xil_printf("th2 : %x \n\r",th[2]);
				xil_printf("th3 : %x \n\r",th[3]);

				break;
			case 'L' :
			case 'l' :
			case '2' :
				xil_printf("Load the string length \n\r");
				cmd_str_len(XPAR_MD5_HASHER_0_BASEADDR, 19);
				break;
			case 'S' :
			case 's' :
			case '3' :
				xil_printf("Status information \n\r");
				u32 status = MD5_HASHER_mReadReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG1_STATUS);
				u32 match_pos = MD5_HASHER_mReadReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG7_MATCH_POS);
				u32 byte_pos = match_pos - 18;
				xil_printf("status {match,done,busy}: %x \n\r",status);
				xil_printf("byte_pos: %d \n\r",byte_pos);
				break;
			case 'R' :
			case 'r' :
			case '4' :
				xil_printf("Run the hasher \n\r");
                status = cmd_send_text(XPAR_MD5_HASHER_0_BASEADDR, DMA_DEV_ID, test_str, sizeof(test_str));
				if (status == XST_SUCCESS)
				{
					xil_printf("Simple DMA returned with XST_SUCCESS");
				}
                while (!isDone(XPAR_MD5_HASHER_0_BASEADDR))
                {
                    // wait
                }
                xil_printf("MD5 hasher completed!!");
                status = cmd_read_match(XPAR_MD5_HASHER_0_BASEADDR, &match, test_str, str_len);
                if (status == XST_SUCCESS)
                {
                    xil_printf("match.pos: %d \n\r",match.pos);
                    xil_printf("match.str: %s \n\r",match.str);
                }
				break;
			case 'Q' :
			case 'q' :
			case '5' :
				xil_printf("item 4, Quit \n\r");
				done = 1;
				break;
    	}

    }

    xil_printf("Bye.\n\n");

    cleanup_platform();
    return 0;
}
