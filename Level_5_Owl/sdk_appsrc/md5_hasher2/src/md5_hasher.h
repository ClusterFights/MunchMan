/*
 * FILE : md5_hasher.h
 *
 * Driver for the md5_hasher core.
 * Starting point was auto-generated by Vivado tools.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 02/21/2019
 */

#ifndef MD5_HASHER_H
#define MD5_HASHER_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"
#include "xil_io.h"

#define MD5_HASHER_REG0_CTRL 		0
#define MD5_HASHER_REG1_STATUS 		4
#define MD5_HASHER_REG2_HASH0 		8
#define MD5_HASHER_REG3_HASH1 		12
#define MD5_HASHER_REG4_HASH2 		16
#define MD5_HASHER_REG5_HASH3 		20
#define MD5_HASHER_REG6_STR_LEN 	24
#define MD5_HASHER_REG7_MATCH_POS	28


/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a MD5_HASHER register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the MD5_HASHERdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void MD5_HASHER_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define MD5_HASHER_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a MD5_HASHER register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the MD5_HASHER device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 MD5_HASHER_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define MD5_HASHER_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/*
***************************
* Structures
***************************
*/

struct match_result
{
    int pos;
    unsigned char str[56];
};

/*
***************************
* Functions
***************************
*/

XStatus dma_init(u16 dma_device_id);

XStatus cmd_set_hash(void* baseaddr_p, unsigned char *target_hash);
XStatus cmd_send_text(void* baseaddr_p, u16 dma_device_id,
            unsigned char* text_str, int text_str_len);
XStatus cmd_read_match(void* baseaddr_p, struct match_result *result,
        u8* text_str, int str_len);
XStatus cmd_str_len(void* baseaddr_p, unsigned char num_chars);

void cmd_reset(void* baseaddr_p);
void cmd_enable(void* baseaddr_p);
void cmd_clear_interrupt(void * baseaddr_p);

u8 isDone(void* baseaddr_p);

#endif // MD5_HASHER_H
