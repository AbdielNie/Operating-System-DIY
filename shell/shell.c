#include "../include/shell.h"
#include "../include/types.h"
#include "../include/GUI.h"

struct struct_layer *shell_layer;

struct shell{
	u32 x;
	u32 y;
	u32 width;
	u32 height;
	u32 cursor;
	u32 size;
	u32 color;
}shell;
void init_shell(void)
{
	/*initialization shell layer*/
	shell_layer = GUI_layer_alloc(&layer_root);
	(*shell_layer).visiable = true;
	GUI_set_position(shell_layer, 0, 0);
	
	/*notice:There are use immediately number to the function,
	 *They will be affect support in different VGA mode
	 */
	
	GUI_set_resolution(shell_layer, 800, 600);
	/*初始化模拟文本模式*/
	shell.width = 100;
	shell.height = 30;
	shell.x = (xsize - (shell.width * 8))/2;
	shell.y = (ysize - (shell.height * 16))/2;
	shell.cursor = 0;
	shell.size = shell.width * shell.height;
	shell.color = 0xffffffff;
	/*display information label*/
	draw_square(0, 0, xsize, 16, 0xff4f2f4f);/*紫罗兰色*/
	put_string(0, 0, 0xffffffff, "Ghost Bird OS 0.02 Alpha.");
	/*display information of kernel and copyright*/
	color(0xffffff00);
	printk("kernel:Explorer 0.01\n");
	color(0xffff0000);
	printk("Copyright 2013-2014 by Explorer Developer. All rights reserved.\n");
	color(0xffffffff);
}
void debug(u32 *address, u32 size)
{
	printk("debug:from 0x%X to 0x%X is:\n", address, address+size);
	for (; size > 0; size -= 4)
	{
		printk("%X ",*address);
		address ++;
	}
	printk("\n");
	return;
}

/*向上滚屏功能函数*/
void scr_up(void)
{
	u32 x,y;
	for (y = shell.y; y < (shell.y + ((shell.height - 1) * 16)); y ++)
	{
		for (x = shell.x; x < (shell.x + (shell.width * 8)); x ++)
		{
			GUI_put_pix(shell_layer, GUI_get_pix(shell_layer, x, (y + 16)), x, y);
			GUI_put_pix(shell_layer, 0x00000000, x, (y + 16));
		}
	}
	shell.cursor -= shell.width;
	return;
}

/*设置颜色*/
void color(u32 color)
{
	shell.color = color;
}

/*输出字*/
void put_font(u8 ascii)
{
	/*换行键的判断*/
	if (ascii == 0x0a)
	{
		shell.cursor -= (shell.cursor % shell.width);
		shell.cursor += shell.width;
		return;
	}
	/*对控制字符的判断*/
	if (ascii < 0x20)
	{
		return;
	}
	/*对是否需要滚屏判断*/
	if (shell.cursor >= shell.size) {
		scr_up();
	}
	/*由模拟文本模式参数到实际图形模式的转换*/
	u32 x, y;
	x = shell.x + (shell.cursor % shell.width) * 8;
	y = shell.y + (shell.cursor / shell.width) * 16;
	/*调用显示函数*/
	draw_font(x, y, shell.color, ascii);
	/*模拟光标指向下一个单位*/
	shell.cursor ++;
}

put_string(u32 x, u32 y, u32 color, u8 *string)
{
	u32 point;
	for (point = 0; string[point] != 0x00; point ++)
	{
		draw_font(x, y, color, string[point]);
		x += 8;
	}
}

/*显示字*/
void draw_font(u32 x, u32 y, u32 color, u8 ascii)
{
	u32 p, i, font_offset;/*字库偏移量*/
	u8 d;
	font_offset = ascii * 16;
	for (i = 0; i < 16; i++)
	{
		d = font[font_offset + i];
		if ((d & 0x80) != 0) { GUI_put_pix(shell_layer, color, x, y + i); }
		if ((d & 0x40) != 0) { GUI_put_pix(shell_layer, color, x + 1, y + i); }
		if ((d & 0x20) != 0) { GUI_put_pix(shell_layer, color, x + 2, y + i); }
		if ((d & 0x10) != 0) { GUI_put_pix(shell_layer, color, x + 3, y + i); }
		if ((d & 0x08) != 0) { GUI_put_pix(shell_layer, color, x + 4, y + i); }
		if ((d & 0x04) != 0) { GUI_put_pix(shell_layer, color, x + 5, y + i); }
		if ((d & 0x02) != 0) { GUI_put_pix(shell_layer, color, x + 6, y + i); }
		if ((d & 0x01) != 0) { GUI_put_pix(shell_layer, color, x + 7, y + i); }
	}
}

void draw_square(u32 x, u32 y, u32 width, u32 height, u32 color)
{
	u32 m, n;
	for (n = 0; n != height; n ++)
	{
		for (m = 0; m != width; m ++)
		{
			GUI_put_pix(shell_layer, color, x + m, y + n);
		}
	}
}
