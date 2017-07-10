#ifndef MEMORY_H
#define MEMORY_H

#include "../include/stddef.h"
#include "../include/macro.h"

u32 *pt;
u32 *pdt;

void inti_memory(void);
void *kmalloc(u32 size);
void kfree(u32 addr, u32 size);
u32 vremap(u32 vir_addr, u32 phy_addr, u32 size);
void kmemcpy(u8 *source, u8 *object, u32 count);
void* memset(void* s, int c, size_t n);
int32 creat_pdt(u32 *point);
int32 copy_pdt(u32 *source_point, u32 *target_point);

#endif