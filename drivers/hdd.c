
#include "../include/hdd.h"
#include "../include/types.h"


unsigned int LBA_start;

void init_hdd(void)
{
	u8 *point;
	point = (char *) kmalloc(512);
	read_disk(0, (unsigned short int*) point, 1);
	kmemcpy((point + 0x1be + 8), &LBA_start, 2);
	kfree(point, 512);
}

void read_disk(u32 LBA, u16 *buffer, u32 number)
{
	u32 offset, i;
	io_out16(0x1f2,number);/*数量*/
	io_out8(0x1f3,(LBA & 0xff));/*LBA地址7~0*/
	io_out8(0x1f4,((LBA >> 8) & 0xff));/*LBA地址15~8*/
	io_out8(0x1f5,((LBA >> 16) & 0xff));/*LBA地址23~16*/
	io_out8(0x1f6,(((LBA >> 24) & 0xff) + 0xe0));/*LBA地址27~24 + LBA模式，主硬盘*/
	io_out8(0x1f7,0x20);/*读扇区*/
	for (i = 0; i != number; i ++)
	{
		hdd_wait();
		for (offset = 0; offset < 256; offset ++)
		{
			buffer[(i * 256) + offset] = io_in16(0x1f0);
		}
	}
	return;
}

void hdd_wait(void)
{
	for (; (io_in8(0x1f7) & 0x88) != 0x08;);/*循环等待*/
}
