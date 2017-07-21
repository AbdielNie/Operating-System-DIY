/*
 *Copyright 2013-2014 by Explorer Developer.
 *made by 迷彩红星<1@GhostBirdOS.org>
 *Explorer 页故障处理程序
 *ExplorerOS/Kernel/memory/do_page_fault.c
 *version:Alpha
 *8/7/2014 10:46 AM
 */

#include <process.h>
#include "../include/memory.h"
#include <types.h>

void do_page_fault(u32 error_code)
{
	printk(".");
	u32 cr2, *pdt_address, old_cr3;
	/*读取信息*/
	cr2 = read_CR2();
	pdt_address = (u32 *) (read_CR3() & 0xfffff000);
	/*换上内核的管理页目录表*/
	old_cr3 = read_CR3();
	write_CR3(pdt);
	if ((error_code == 2) | (error_code == 0))/*是缺页引发的中断*/
	{
		if ((pdt_address[(cr2 >> 22)] & 1) == 0)/*如果没有页表*/
		{
			pdt_address[(cr2 >> 22)] = (get_free_page() | 0x7);
			/*清空这个页*/
			memset((u8 *) (pdt_address[(cr2 >> 22)]), 0x00, ((4096 - 256) / 4));/*对后面的内存区域必须清0*/
		}
		/*一定缺少页*/
		((u32 *) (pdt_address[(cr2 >> 22)] & 0xfffff000))[(cr2 & 0x3FF000) >> 12] = (get_free_page() | 0x7);
		/*显示信息及返回*/
		//printk("Page fault:allocated.%X",pdt_address[(cr2 >> 22)]);
		write_CR3(old_cr3);
		return;
	}else{
	color(0xffff00);
	printk("Page fault:(Unknown)error code:0x%X", error_code);
	io_hlt();
	}
}


