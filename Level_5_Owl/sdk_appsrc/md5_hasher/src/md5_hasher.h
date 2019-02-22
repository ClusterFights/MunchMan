
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

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the MD5_HASHER instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus MD5_HASHER_Reg_SelfTest(void * baseaddr_p);

#endif // MD5_HASHER_H
