/*Explorer 0.01 内存管理部分代码*/
#include <stddef.h>
#include "../include/address.h"
#include "../include/memory.h"
#include <types.h>

struct mem_map{
	unsigned int start;
	unsigned int end;
}(*mem_map);

struct k_mem_map{
	unsigned int start;
	unsigned int end;
}(*k_mem_map);

/*void init_memory(void)功能：
	建立内核可分配内存区间表
		依据内存可分配区间表建立256MB的内核空间可分配内存区间表
	将内存可分配区间表的低256MB设为占用
	进入分页模式
		建立页目录表
		建立页表
*/
	
void init_memory(void)
{
	/*使两个表指针指向内存空间*/
	mem_map = (struct mem_map *) mem_map_addr;
	k_mem_map = (struct k_mem_map *) k_mem_map_addr;
	u32 offset;
	/*将内存分布区间图中低256MB的分布情况拷贝到内核内存分布图*/
	for (offset = 0; mem_map[offset].end != 0; offset ++)
	{
		k_mem_map[offset].start = mem_map[offset].start;
		if (mem_map[offset].end >= 256 MB)
		{
			k_mem_map[offset].end = 256 MB;
		}else{
			k_mem_map[offset].end = mem_map[offset].end;
		}
	}
	
	/*将内存可分配区间表的低256MB设为占用*/
	for (offset = 0; mem_map[offset].start <= 256 MB & mem_map[offset].start != 0; offset ++)
	{
		if (mem_map[offset].end <= 256 MB)
		{
			/*将这段在前256MB区间的空闲内存作为没有处理*/
			mem_map[offset].start = 0;
			mem_map[offset].end = 0;
		}else{
			/*大于256MB的自由内存区间从256MB开始*/
			mem_map[offset].start = 256 MB;
			goto prepare_paging;
		}
	}

/**
 *creat PDT and PT
 *
 */

prepare_paging:
	pdt = (int *)kmalloc(4096);
	pt = (int *)kmalloc(4096 * 1024);
	for (offset = 0; offset < 1024; offset ++)
	{
		pdt[offset] = (offset * 0x1000) + (int)pt + 0x7;
	}
	for (offset = 0; offset < 1048576; offset ++)
	{
		pt[offset] = offset * 0x1000 + 0x7;
	}
	goto_paging(pdt);
}

u32 get_free_page(void)
{
	u32 offset, ret_value;
	for (offset = 0; offset < mem_map_len; offset ++)
	{
		if (mem_map[offset].end != 0)
		{
			ret_value = mem_map[offset].start;
			mem_map[offset].start += 0x1000;
			if (mem_map[offset].start == mem_map[offset].end)
			{
				mem_map[offset].start = 0;
				mem_map[offset].end = 0;
			}
			//printk("get_free_page:0x%X.\n",ret_value);
			return ret_value;
		}
	}
	
	/**
	 *it must be in the end of find
	 *without available memory when running here
	 */
	
	color(0xffff00);
	printk("Page allocation error: not enough!");
	io_hlt();
}

/**
 *stand function in kernel
 *void *vmalloc(unsigned long size);
 *void *kmalloc(size_t size, int flags);
 */
void *kmalloc(size_t size)
{
	int offset, addr;
	//为了尽快完成，目前暂时对非4KB倍的请求拒绝
	if ((size & 0xfff) != 0)
	{
		size = ((size & 0xfffff000) + 0x1000);
	}
	for (offset = 0; offset < k_mem_map_len; offset ++)
	{
		if ((k_mem_map[offset].end - k_mem_map[offset].start) == size)
		{
			addr = k_mem_map[offset].start;
			k_mem_map[offset].start = 0;
			k_mem_map[offset].end = 0;
			return (void *) addr;
		}else if ((k_mem_map[offset].end - k_mem_map[offset].start) > size)
		{
			addr = k_mem_map[offset].start;
			k_mem_map[offset].start += size;
			return (void *) addr;
		}
	}
	
	/**
	 *warning:there is end of system as a result of there is no enough memory,
	 *it will be error before running to here with no initialization of shell
	 *because the function color and printk belong to shell.
	 */
	
	color(0xffff00);
	printk("kmalloc is error:Not enough memory!");
	io_hlt();
}
/*内核内存释放*/
void kfree(u32 addr, unsigned int size)
{
}
/*虚拟空间映射*/
unsigned int kmap(unsigned int vir_addr, unsigned int phy_addr, unsigned int size)
{
	if ((vir_addr & 0xfff) != 0)
	{
		return 1;
	}
	if ((phy_addr & 0xfff) != 0)
	{
		return 2;
	}
	if ((size & 0xfff) != 0)
	{
		return 3;
	}
	for (;size != 0;size -= 0x1000)
	{
		pt[(vir_addr >> 12)] = phy_addr + 0x7;
		phy_addr += 0x1000;
		vir_addr += 0x1000;
	}
	return 0;
}

void kmemcpy(u8 *source, u8 *object, u32 count)
{
	unsigned int i;
	for(i = 0; i < count; i ++)
	{
		object[i] = source[i];
	}
	return;
}

/*内存清零函数*/
void* memset(void* s, int c, size_t n)
{
    unsigned char* p = (unsigned char*) s;
    while (n > 0) {
    *p++ = (unsigned char) c;
    --n;
    }
    return s;
}

/*创建页目录表*/
int32 creat_pdt(u32 *point)
{
	u32 offset;
	for (offset = 0; offset < 64; offset ++)/*只用创建256MB内核区的表项就够了*/
	{
		point[offset] = (offset * 0x1000) + (int)pt + 0x7;
	}
	memset((u8 *) (&point[offset + 1]), 0x00, ((4096 - 256) / 4));/*对后面的内存区域必须清0*/
	return 0;
}

/*未完工*/
int32 copy_pdt(u32 *source_point, u32 *target_point)
{
	u32 i;
	for (i = 0; i<1024; i ++)
	{
		target_point[i] = source_point[i];
	}
	return 0;
}
