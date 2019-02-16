#ifndef _KBINPUT_H_
#define _KBINPUT_H_

#ifdef __cplusplus
extern "C" {
#endif

int kbinput_read(void);
int kbinput_read_block(time_t timeout_sec);

#ifdef __cplusplus
}
#endif

#endif

