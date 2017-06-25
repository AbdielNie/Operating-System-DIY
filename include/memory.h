/*
 *Copyright 2013-2014 by Explorer Developer.
 *made by 迷彩红星<1@GhostBirdOS.org>
 *Explorer 主函数头文件
 *ExplorerOS/Kernel/include/memory.h
 *version:Alpha
 *7/9/2014 8:30 AM
 */

#ifndef MEMORY_H
#define MEMORY_H

#include "../include/stddef.h"
#include "../include/types.h"

u32 *pt;
u32 *pdt;

void inti_memory(void);
void *kmalloc(u32 size);
void kfree(u32 addr, u32 size);
u32 kmap(u32 vir_addr, u32 phy_addr, u32 size);
void kmemcpy(u8 *source, u8 *object, u32 count);
void* memset(void* s, int c, size_t n);
int32 creat_pdt(u32 *point);
int32 copy_pdt(u32 *source_point, u32 *target_point);

#endif