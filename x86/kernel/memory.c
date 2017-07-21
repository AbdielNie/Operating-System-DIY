/*Explorer 0.01 �ڴ�����ִ���*/
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

/*void init_memory(void)���ܣ�
	�����ں˿ɷ����ڴ������
		�����ڴ�ɷ����������256MB���ں˿ռ�ɷ����ڴ������
	���ڴ�ɷ��������ĵ�256MB��Ϊռ��
	�����ҳģʽ
		����ҳĿ¼��
		����ҳ��
*/
	
void init_memory(void)
{
	/*ʹ������ָ��ָ���ڴ�ռ�*/
	mem_map = (struct mem_map *) mem_map_addr;
	k_mem_map = (struct k_mem_map *) k_mem_map_addr;
	u32 offset;
	/*���ڴ�ֲ�����ͼ�е�256MB�ķֲ�����������ں��ڴ�ֲ�ͼ*/
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
	
	/*���ڴ�ɷ��������ĵ�256MB��Ϊռ��*/
	for (offset = 0; mem_map[offset].start <= 256 MB & mem_map[offset].start != 0; offset ++)
	{
		if (mem_map[offset].end <= 256 MB)
		{
			/*�������ǰ256MB����Ŀ����ڴ���Ϊû�д���*/
			mem_map[offset].start = 0;
			mem_map[offset].end = 0;
		}else{
			/*����256MB�������ڴ������256MB��ʼ*/
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
	//Ϊ�˾�����ɣ�Ŀǰ��ʱ�Է�4KB��������ܾ�
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
/*�ں��ڴ��ͷ�*/
void kfree(u32 addr, unsigned int size)
{
}
/*����ռ�ӳ��*/
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

/*�ڴ����㺯��*/
void* memset(void* s, int c, size_t n)
{
    unsigned char* p = (unsigned char*) s;
    while (n > 0) {
    *p++ = (unsigned char) c;
    --n;
    }
    return s;
}

/*����ҳĿ¼��*/
int32 creat_pdt(u32 *point)
{
	u32 offset;
	for (offset = 0; offset < 64; offset ++)/*ֻ�ô���256MB�ں����ı���͹���*/
	{
		point[offset] = (offset * 0x1000) + (int)pt + 0x7;
	}
	memset((u8 *) (&point[offset + 1]), 0x00, ((4096 - 256) / 4));/*�Ժ�����ڴ����������0*/
	return 0;
}

/*δ�깤*/
int32 copy_pdt(u32 *source_point, u32 *target_point)
{
	u32 i;
	for (i = 0; i<1024; i ++)
	{
		target_point[i] = source_point[i];
	}
	return 0;
}
