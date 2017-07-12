/*
 *Copyright 2013-2014 by Explorer Developer.
 *made by 迷彩红星<1@GhostBirdOS.org>
 *Explorer 8259\定时器支持程序头文件
 *ExplorerOS\Kernel\include\timer.h
 *version:Alpha
 *7/28/2014 2:20 PM
 */

#ifndef TIMER_H_
#define TIMER_H_

#include "types.h"

#define PIT_CTRL	0x0043
#define PIT_CNT0	0x0040

extern int_timer;

void init_timer(void);
void int_timer_display(void);
void init_pit(void);

#endif
