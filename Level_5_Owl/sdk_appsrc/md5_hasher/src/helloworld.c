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

static XAxiDma AxiDma;

// target md5 hash for "The quick brown fox"
static u32 target_hash[] = {
    0xa2004f37,
    0x730b9445,
    0x670a738f,
    0xa0fc9ee5
};

static unsigned char test_str[] = "Hello. The quick brown fox jumps over the lazy dog.";

/*****************************************************************************/
/**
* The example to do the simple transfer through polling. The constant
* NUMBER_OF_TRANSFERS defines how many times a simple transfer is repeated.
*
* @param	DeviceId is the Device Id of the XAxiDma instance
*
* @return
*		- XST_SUCCESS if example finishes successfully
*		- XST_FAILURE if error occurs
*
* @note		None
*
*
******************************************************************************/
int XAxiDma_SimplePollExample(u16 DeviceId, u8* TxBufferPtr, int buffer_size)
{
	XAxiDma_Config *CfgPtr;
	int Status;

	xil_printf("buffer_size: %d \n\r",buffer_size);


	/* Initialize the XAxiDma device.
	 */
	CfgPtr = XAxiDma_LookupConfig(DeviceId);
	if (!CfgPtr) {
		xil_printf("No config found for %d\r\n", DeviceId);
		return XST_FAILURE;
	} else
	{
		xil_printf("Config found for %d\r\n", DeviceId);
	}

	Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Initialization failed %d\r\n", Status);
		return XST_FAILURE;
	} else
	{
		xil_printf("Initialization passed %d\r\n", Status);
	}

	if(XAxiDma_HasSg(&AxiDma)){
		xil_printf("Device configured as SG mode \r\n");
		return XST_FAILURE;
	} else
	{
		xil_printf("Device configured as Simple mode \r\n");
	}

	/* Disable interrupts, we use polling mode
	 */
	xil_printf("Disable interrupts \r\n");
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
						XAXIDMA_DEVICE_TO_DMA);



	/* Flush the SrcBuffer before the DMA transfer, in case the Data Cache
	 * is enabled
	 */
	xil_printf("Flush the Data Cache \r\n");
	Xil_DCacheFlushRange((UINTPTR)TxBufferPtr, buffer_size);


	/* Start the transfer */
	xil_printf("Start the transfer \r\n");
	Status = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) TxBufferPtr,
			buffer_size, XAXIDMA_DMA_TO_DEVICE);

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	xil_printf("Wait for Dma to finish. \r\n");
	while (XAxiDma_Busy(&AxiDma,XAXIDMA_DMA_TO_DEVICE)) {
			/* Wait */
	}


	/* Test finishes successfully
	 */
	return XST_SUCCESS;
}

/*
 * cmd_str_len : Sets up the str_len in the md5_hasher core
 * returns: 1 for success, 0 for fail.
 */
u8 cmd_str_len(u8 num_chars)
{
    u32 num_bits;
    u32 ret;

    // Check the num_chars are in range
    if (num_chars <2 || num_chars > 55)
    {
        xil_printf("ERROR cmd_str_len num_chars out of range: %d\n\r",num_chars);
        return 0;
    }

    // compute number of bits and write to array in big endian
    num_bits = num_chars*8;
    xil_printf("num_bits: %x \n\r",num_bits);

    // Write to the core
    MD5_HASHER_mWriteReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG6_STR_LEN, num_bits);

    // Read num_bits back
    ret = MD5_HASHER_mReadReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG6_STR_LEN);
    xil_printf("num_bits ret: %x \n\r",ret);

    return 1;

}

void menu()
{
	xil_printf("\n\r\n\rMenu\n\r");
	xil_printf("1 : (H)ash \n\r");
	xil_printf("2 : (L)ength str \n\r");
	xil_printf("3 : (S)tatus \n\r");
	xil_printf("4 : (R)un hasher \n\r");
	xil_printf("5 : (Q)uit\n\r");
}

int main()
{
    char c;
    int done=0;
    int status;

    init_platform();


    while(!done)
    {
    	menu();
    	c=inbyte();
		printf("\n\rOption Selected : %c \n\r",c);

    	switch(c)
    	{
    		case 'H' :
    		case 'h' :
			case '1' :
				xil_printf("Reset core\n\r");
				MD5_HASHER_mWriteReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG0_CTRL, 0x01);

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
				cmd_str_len(19);
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
				xil_printf("Toggle the start bit reg0[1] \n\r");
				MD5_HASHER_mWriteReg(XPAR_MD5_HASHER_0_BASEADDR, MD5_HASHER_REG0_CTRL, 0x02);
				xil_printf("Start DMA \n\r");
				status = XAxiDma_SimplePollExample(DMA_DEV_ID, test_str, sizeof(test_str));
				if (status == XST_SUCCESS)
				{
					xil_printf("Simple DMA finished with XST_SUCCESS");
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
