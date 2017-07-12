/*
 *Copyright 2013-2014 by Explorer Developer.
 *made by �Բʺ���<1@GhostBirdOS.org>
 *Explorer �ں�shellƽ̨֧�ִ���ͷ
 *ExplorerOS/Kernel/include/shell.h
 *version:Alpha
 *7/5/2014 7:08 PM
 */

#ifndef SHELL
#define SHELL

#include "types.h"

//�ֿ�
extern u8 font[256*16];
//��Ļ���
extern u32 xsize;
extern u32 ysize;

void inti_shell(void);
/*���������ʱ�û�����*/
void printk(const u8* format, ...);
int printf(const char *format,...);
void debug(u32 *address, u32 size);
void color(u32 color);
void put_font(u8 ascii);
void draw_font(u32 x, u32 y, u32 color, u8 ascii);
void draw_square(u32 x, u32 y, u32 width, u32 height, u32 color);

#endif