/*
 *Copyright 2013-2014 by 2013-2014 by Explorer OS Developer. All rights reserved.
 *made by 迷彩红星<1@GhostBirdOS.org>
 *Explorer 0.01 io.asm头文件
 *Explorer/Kernel/include/HAL/x86/io.h
 *7/26/2014 7:05 PM
 */

#ifndef IO_H_
#define IO_H_

#include "../../types.h"

//输入输出函数
void io_hlt(void);
void io_cli(void);
void io_sti(void);
u32 io_read_eflags();
void io_write_eflags(int flags);
u8 io_in8(u32 port);
u16 io_in16(u32 port);
u32 io_in32(u32 port);
void io_out8(u32 port, u8 data);
void io_out16(u32 port, u8 data);
void io_out32(u32 port, u8 data);

#endif
