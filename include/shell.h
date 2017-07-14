#ifndef SHELL
#define SHELL

#include "types.h"

//字库
extern u8 font[256*16];
//屏幕宽度
extern u32 xsize;
extern u32 ysize;

void inti_shell(void);
/*这个函数临时用汇编完成*/
void printk(const u8* format, ...);
int printf(const char *format,...);
void debug(u32 *address, u32 size);
void color(u32 color);
void put_font(u8 ascii);
void draw_font(u32 x, u32 y, u32 color, u8 ascii);
void draw_square(u32 x, u32 y, u32 width, u32 height, u32 color);

#endif
