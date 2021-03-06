/*
 * FILE: main.c: 
 *
 * ClusterFighting MD5 Hash Search application.
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *
 *   ps7_uart    115200 (configured by bootrom/bsp)
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 02/22/2019
 */

#include "xparameters.h"
#include "platform.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "md5_hasher.h"
#include <stdio.h>
#include <stdlib.h>
#include "xaxidma.h"
#include "find_lib.h"
#include "xgpio.h"
#include "xtime_l.h"


#define DMA_DEV_ID      XPAR_AXIDMA_0_DEVICE_ID
#define MD5_BASEADDR    XPAR_MD5_HASHER_0_BASEADDR
#define GPIO_DEV_ID  	XPAR_GPIO_0_DEVICE_ID

#define RGB_CHANNEL 1
// blue =1, green =2, red =4
#define RGB_OFF		0
#define RGB_BLUE	1
#define RGB_GREEN	2
#define RGB_RED		3

#define LED_CHANNEL 2


// target md5 hash for "The quick brown fox"
/*
static u32 target_hash[] = {
    0xa2004f37,
    0x730b9445,
    0x670a738f,
    0xa0fc9ee5
};
*/

// 'The quick brown fox'
// str_len = 19
// md5: a2004f37730b9445670a738fa0fc9ee5
static unsigned char test_str[] = "HHello. The quick brown fox jumps over the lazy dog.";

void menu(char* md5_hash, int str_len)
{
	xil_printf("\n\r\n\rMenu\n\r");
	xil_printf("0 : (R)eset \n\r");
	xil_printf("1 : (H)ash: %s \n\r",md5_hash);
	xil_printf("2 : (L)ength: %d  \n\r",str_len);
	xil_printf("3 : (S)tatus \n\r");
	xil_printf("4 : (G)o run hasher \n\r");
	xil_printf("5 : (Q)uit\n\r");
	xil_printf("6 : s(D)card test \n\r");
}

int main()
{
    char c;
    int done=0;
    int ret;
    u8 status_bits;
    struct match_result match;
    u8* mem_text = NULL;

    char md5_hash[33] = {
        48,48,48,48,48,48,48,48,
        48,48,48,48,48,48,48,48,
        48,48,48,48,48,48,48,48,
        48,48,48,48,48,48,48,48,0
    };
    char in_md5_hash[33];
    unsigned char target_hash[16] = {0};
    unsigned char in_target_hash[16] = {0};

    int str_len = 0;
    int in_str_len = 0;

    XGpio Gpio; /* The Instance of the GPIO Driver */

    XTime tStart, tEnd;
    double total_time, hashes_per_sec;

    u8* match_str[56];

    int byte_offset=0;
    int byte_pos=0;

    init_platform();

    // Init the md5_hasher and DMA engine
    cmd_reset(MD5_BASEADDR);
    dma_init(DMA_DEV_ID);

    /* Initialize the GPIO driver */
    ret = XGpio_Initialize(&Gpio, GPIO_DEV_ID);
    if (ret != XST_SUCCESS) {
        xil_printf("Gpio Initialization Failed\r\n");
    }
    /* Set the direction as output for all */
    XGpio_SetDataDirection(&Gpio, RGB_CHANNEL, 0);  // channel 1, 0=all outputs
    XGpio_SetDataDirection(&Gpio, LED_CHANNEL, 0);  // channel 2, 0=all outputs
    XGpio_DiscreteWrite(&Gpio, RGB_CHANNEL, RGB_OFF);
    XGpio_DiscreteWrite(&Gpio, LED_CHANNEL, 0x00);

    while(!done)
    {
        menu(md5_hash, str_len);
        c=inbyte();
        xil_printf("\n\rOption Selected : %c \n\r",c);

        switch(c)
        {
            case 'R' :
            case 'r' :
            case '0' :
                xil_printf("Reset MD5 hasher core.\n\r");
                cmd_reset(MD5_BASEADDR);
                str_len = 0;
                in_str_len = 0;
                for (int i=0; i<32; i++)
                {
                    md5_hash[i] = 48;
                    in_md5_hash[i] = 48;
                    if (i<16)
                    {
                        target_hash[i] = 0;
                        in_target_hash[i] = 0;
                    }
                }
                XGpio_DiscreteWrite(&Gpio, RGB_CHANNEL, RGB_OFF);
                break;
            case 'H' :
            case 'h' :
            case '1' :
                xil_printf("\nEnter Hash: \n\r");
                ret = scanf("%s",in_md5_hash);
                if (ret == EOF)
                {
                    xil_printf("ERROR scanf returned EOF\n\r");
                    break;
                }
                if (convert_hash(in_md5_hash, in_target_hash))
                {
                    strcpy(md5_hash,in_md5_hash);
                    xil_printf("md5_hash_bytes: ");
                    for (int i=0; i<16; i++)
                    {
                        target_hash[i] = in_target_hash[i];
                        xil_printf("%.2x ",target_hash[i]);
                    }
                    xil_printf("\n\r");
                    // Send new target_hash to board
                    ret = cmd_set_hash(MD5_BASEADDR, target_hash);
                    if (ret != XST_SUCCESS)
                    {
                        xil_printf("ERROR: cmd_set_hash() failed.\n\r");
                    }
                } else
                {
                    xil_printf("ERROR: convert_hash() failed.\n\r");
                }
                XGpio_DiscreteWrite(&Gpio, RGB_CHANNEL, RGB_OFF);
                break;
            case 'L' :
            case 'l' :
            case '2' :
                xil_printf("\n\rEnter String Length: \n\r");
                ret = scanf("%d",&in_str_len);
                if (ret == EOF)
                {
                    xil_printf("ERROR scanf returned EOF\n\r");
                    break;
                }
                str_len = in_str_len;
                cmd_str_len(MD5_BASEADDR, str_len);
                XGpio_DiscreteWrite(&Gpio, RGB_CHANNEL, RGB_OFF);
                break;
            case 'S' :
            case 's' :
            case '3' :
                xil_printf("Status information \n\r");
                u32 status = MD5_HASHER_mReadReg(MD5_BASEADDR, MD5_HASHER_REG1_STATUS);
                u32 match_pos = MD5_HASHER_mReadReg(MD5_BASEADDR, MD5_HASHER_REG7_MATCH_POS);
                u32 byte_pos = match_pos - 18;
                xil_printf("status {match,done,busy}: %x \n\r",status);
                xil_printf("byte_pos: %d \n\r",byte_pos);
                XGpio_DiscreteWrite(&Gpio, RGB_CHANNEL, RGB_OFF);
                break;
            case 'G' :
            case 'g' :
            case '4' :
                xil_printf("Go Run the hasher \n\r");
                XGpio_DiscreteWrite(&Gpio, RGB_CHANNEL, RGB_BLUE);
                XTime_GetTime(&tStart);
                cmd_enable(MD5_BASEADDR);
                status = cmd_send_text(MD5_BASEADDR, DMA_DEV_ID, mem_text, DATA_TXT_SIZE, &byte_offset);
                xil_printf("byte_offset: %d \n\r",byte_offset);
                if (status == XST_FAILURE)
                {
                    xil_printf("ERROR: cmd_send_text returned XST_FAILURE.\n\r");
                }
                while (!(status_bits=isDone(MD5_BASEADDR)))
                {
                    // wait
                }
                XTime_GetTime(&tEnd);
                total_time = elapsed_time(tStart, tEnd);
                xil_printf("MD5 hasher completed!!\n\r");
                status = cmd_read_match(MD5_BASEADDR, &match, mem_text, str_len);
                if (status_bits >1) // match occured
                {
                    to_byte_str(match.str, match_str, str_len);
                    byte_pos = byte_offset + match.pos;
                    xil_printf("match.pos: %d \n\r",byte_pos);
                    xil_printf("match.str: %s \n\r",match_str);
                    hashes_per_sec = (match.pos+1) / total_time;
                    XGpio_DiscreteWrite(&Gpio, RGB_CHANNEL, RGB_GREEN);
                } else
                {
                    xil_printf("!!! NO MATCH !!! \n\r");
                    hashes_per_sec = (match.pos+1) / DATA_TXT_SIZE;
                    XGpio_DiscreteWrite(&Gpio, RGB_CHANNEL, RGB_RED);
                }
                printf ("Total time = %f seconds\n\r", total_time);
                printf("hashes_per_sec: %f\n\r",hashes_per_sec);
                cmd_clear_interrupt(MD5_BASEADDR);
                break;
            case 'Q' :
            case 'q' :
            case '5' :
                xil_printf("item 4, Quit \n\r");
                done = 1;
                break;
            case 'D' :
            case 'd' :
            case '6' :
                xil_printf("Running SDCard Load...\n\r");
                mem_text = sdcard_load();
                if (mem_text == NULL)
                {
                    xil_printf("SDCard Load Failed!\n\r");
                } else
                {
                    xil_printf("SDCard Load Passed!\n\r");
                }

                break;
        }
    }

    xil_printf("Bye.\n\n");

    cleanup_platform();
    return 0;
}

