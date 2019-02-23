/*
 * FILE : md5_hasher.c
 *
 * Driver for the md5_hasher core.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 02/21/2019
 */

#include "md5_hasher.h"
#include "xaxidma.h"

#define MD5_BASEADDR    XPAR_MD5_HASHER_0_BASEADDR

static XAxiDma AxiDma;

/*
 * isDone : Checks if the md5_hasher is done running
 * PARAMS:
 *   baseaddr_p : BASE address of the md5_hasher core.
 *
 * RETURNS: 0 if still processing, 1 done with dma, 2 match.
 */
u8 isDone(void * baseaddr_p)
{
    u32 status = MD5_HASHER_mReadReg(baseaddr_p, MD5_HASHER_REG1_STATUS);
    // status bits {match, done, busy}
    return (u8)(status>>1);
}

/*
 * cmd_set_hash : Set the target hash.
 * PARAMS:
 *   baseaddr_p : BASE address of the md5_hasher core.
 *   target_hash : 16 hex bytes, index 0 is MSB.
 *
 * RETURNS: XST_SUCCESS or XST_FAILURE
 */
XStatus cmd_set_hash(void * baseaddr_p, unsigned char *target_hash)
{
    u32 th_reg[4];

    th_reg[0] = (target_hash[0]<<24) | (target_hash[1]<<16) | (target_hash[2]<<8) | target_hash[3];
    th_reg[1] = (target_hash[4]<<24) | (target_hash[5]<<16) | (target_hash[6]<<8) | target_hash[7];
    th_reg[2] = (target_hash[8]<<24) | (target_hash[9]<<16) | (target_hash[10]<<8) | target_hash[11];
    th_reg[3] = (target_hash[12]<<24) | (target_hash[13]<<16) | (target_hash[14]<<8) | target_hash[15];

    MD5_HASHER_mWriteReg(baseaddr_p, MD5_HASHER_REG2_HASH0, th_reg[0]);
    MD5_HASHER_mWriteReg(baseaddr_p, MD5_HASHER_REG3_HASH1, th_reg[1]);
    MD5_HASHER_mWriteReg(baseaddr_p, MD5_HASHER_REG4_HASH2, th_reg[2]);
    MD5_HASHER_mWriteReg(baseaddr_p, MD5_HASHER_REG5_HASH3, th_reg[3]);

    return XST_SUCCESS;
}


/*
 * dma_init : Initialize the dma device
 * PARAMS:
 *   dma_device_id  : The device ID of the DMA to use.
 *
 * RETURNS: XST_SUCCESS or XST_FAILURE
 */
XStatus dma_init(u16 dma_device_id)
{
    XAxiDma_Config *CfgPtr;
    XStatus Status;

    /* Initialize the XAxiDma device.
     */
    CfgPtr = XAxiDma_LookupConfig(dma_device_id);
    if (!CfgPtr) {
        xil_printf("No config found for %d\r\n", dma_device_id);
        return XST_FAILURE;
    } else
    {
        xil_printf("Config found for %d\r\n", dma_device_id);
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

    return XST_SUCCESS;
}


/*
 * cmd_send_text : Sends a block of text via DMA to the md5_hasher core.
 *      Non blocking.
 * PARAMS:
 *   baseaddr_p     : BASE address of the md5_hasher core.
 *   dma_device_id  : The device ID of the DMA to use.
 *   text_str       : Pointer to the text block in memory.
 *   text_str_len   : Number of chars to send.
 *
 * RETURNS: XST_SUCCESS or XST_FAILURE
 */
XStatus cmd_send_text(void * baseaddr_p, u16 dma_device_id, 
            u8* text_str, int text_str_len, int *byte_offset)
{
    XStatus Status;
    u8 ret;
    u8* text_str_ptr = text_str;

    /* Flush before the DMA transfer, in case the Data Cache
     * is enabled
     */
    // XXX xil_printf("Flush the Data Cache \r\n");
    Xil_DCacheFlushRange((UINTPTR)text_str, text_str_len);


    /* Start the transfer */
    // XXX xil_printf("Start the transfer \r\n");
    int num_loops = text_str_len / DMA_SIZE;
    int remainder = text_str_len % DMA_SIZE;

    *byte_offset=0;
    for (int i=0; i<num_loops; i++)
    {
        Status = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) text_str_ptr,
                DMA_SIZE, XAXIDMA_DMA_TO_DEVICE);

        if (Status != XST_SUCCESS) {
            xil_printf("ERROR: during XAxiDma_SimpleTransfer() \n\r");
            return XST_FAILURE;
        }
        while (!(ret = isDone(MD5_BASEADDR)))
        {
            // wait
        }
        if (ret == 2)
        {
            // match
            break;
        }
        text_str_ptr += DMA_SIZE;
        *byte_offset += DMA_SIZE;
    }

    // Process remainder.
    Status = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) text_str_ptr,
            remainder, XAXIDMA_DMA_TO_DEVICE);

    if (Status != XST_SUCCESS) {
        xil_printf("ERROR: during XAxiDma_SimpleTransfer() \n\r");
        return XST_FAILURE;
    }

    /*
    xil_printf("Wait for Dma to finish. \r\n");
    while (XAxiDma_Busy(&AxiDma,XAXIDMA_DMA_TO_DEVICE)) {
            // wait
    }
    */

    /* Test finishes successfully
     */
    return XST_SUCCESS;

}

/*
 * cmd_read_match : Reads the match position, and string.
 * PARAMS:
 *   baseaddr_p     : BASE address of the md5_hasher core.
 *   result         : This structure holds the match results.
 *   text_str       : Pointer to the text block in memory.
 *   str_len        : Length of the match string.
 *
 * RETURNS: XST_SUCCESS or XST_FAILURE
 */
XStatus cmd_read_match(void * baseaddr_p, struct match_result *result, 
        u8* text_str, int str_len)
{
    u32 status = MD5_HASHER_mReadReg(baseaddr_p, MD5_HASHER_REG1_STATUS);
    if (status <4)
    {
        xil_printf("ERROR: Match not found: status_reg: %x \n\r",status);
        return XST_FAILURE;
    }
    u32 match_pos = MD5_HASHER_mReadReg(baseaddr_p, MD5_HASHER_REG7_MATCH_POS);
    result->pos = match_pos - (str_len-1);
    strncpy((char *)result->str,(char *)&text_str[result->pos],str_len);
    result->str[str_len] = '\0';

    return XST_SUCCESS;
}

/*
 * cmd_str_len : Set the target string length.
 * PARAMS:
 *   baseaddr_p     : BASE address of the md5_hasher core.
 *   num_chars      : String length in characters.
 *
 * RETURNS: XST_SUCCESS or XST_FAILURE
 */
XStatus cmd_str_len(void * baseaddr_p, unsigned char num_chars)
{
    u32 num_bits;
    XStatus ret;

    // Check the num_chars are in range
    if (num_chars <2 || num_chars > 55)
    {
        xil_printf("ERROR cmd_str_len num_chars out of range: %d\n\r",num_chars);
        return XST_FAILURE;
    }

    // compute number of bits and write to array in big endian
    num_bits = num_chars*8;
    xil_printf("num_bits: %x \n\r",num_bits);

    // Write to the core
    MD5_HASHER_mWriteReg(baseaddr_p, MD5_HASHER_REG6_STR_LEN, num_bits);

    return XST_SUCCESS;
}

/*
 * cmd_reset : Reset the md5_hasher core.
 * PARAMS:
 *   baseaddr_p     : BASE address of the md5_hasher core.
 */
void cmd_reset(void * baseaddr_p)
{
    // ctrl_reg = {clear_int, enable, reset}
    MD5_HASHER_mWriteReg(baseaddr_p, MD5_HASHER_REG0_CTRL, 0x01);
}

/*
 * cmd_enable : Enable the md5_hasher core.
 * PARAMS:
 *   baseaddr_p     : BASE address of the md5_hasher core.
 */
void cmd_enable(void * baseaddr_p)
{
    // ctrl_reg = {clear_int, enable, reset}
    MD5_HASHER_mWriteReg(baseaddr_p, MD5_HASHER_REG0_CTRL, 0x02);
}

/*
 * cmd_clear_interrupt : Clear the match interrupt.
 * PARAMS:
 *   baseaddr_p     : BASE address of the md5_hasher core.
 */
void cmd_clear_interrupt(void * baseaddr_p)
{
    // ctrl_reg = {clear_int, enable, reset}
    MD5_HASHER_mWriteReg(baseaddr_p, MD5_HASHER_REG0_CTRL, 0x04);
}


