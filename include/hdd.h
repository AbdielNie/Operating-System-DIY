#ifndef HDD_H_
#define HDD_H_

#include "types.h"

u32 LBA_start;
void inti_hdd(void);
void read_disk(u32 LBA, u16 *buffer, u32 number);
void hdd_wait(void);

#endif

