
#include "../include/process.h"
#include "../include/main.h"
#include "../include/types.h"
#include "../include/memory.h"
#include "../include/fat32.h"
#include "../include/HAL/x86/function.h"

/*初始化进程，目前有个神秘错误导致复制子进程不能返回上一函数*/
void init_process(void)
{
	/*初始化kernel_thread枚举中的thread_info结构体的一些信息*/
	/*esp0由时钟中断写*/
	kernel_thread.thread_info.cr3 = pdt;
	kernel_thread.thread_info.ppid = 0;
	kernel_thread.thread_info.next_thread_union = &kernel_thread;
	kernel_thread.thread_info.pid = 0;
	kernel_thread.thread_info.thread_id = 0;
	kernel_thread.thread_info.count = 5;
	kernel_thread.thread_info.default_count = 5;
	/*将thread_union_point指向kernel_thread*/
	thread_union_point = &kernel_thread;
	/*设定创建进程id起始值*/
	creat_process_id = 1;
	/*设定创建线程id起始值*/
	creat_thread_id = 1;
	/*初始化时钟*/	
	init_timer();
}

void Creat_process(u8 *filename)
{
	/*创建个新PCB*/
	union thread_union *new_process;
	new_process = (union thread_union *) kmalloc(sizeof(union thread_union));
	/*创建个新CR3*/
	u32 *new_cr3;
	new_cr3 = (u32 *) get_free_page();
	creat_pdt(new_cr3);
	/*填写新PCB的各个信息*/
	(*new_process).thread_info.cr3 = pdt;//new_cr3;
	(*new_process).thread_info.ppid = (*thread_union_point).thread_info.pid;
	(*new_process).thread_info.pid = creat_process_id;
	creat_process_id ++;
	(*new_process).thread_info.thread_id = creat_thread_id;
	creat_thread_id ++;
	(*new_process).thread_info.count = 5;
	(*new_process).thread_info.default_count = 5;
	/*设置新进程文件*/
	u32 point;
	for (point = 0; (point > 32) && (filename[point] != 0x00); point ++)
	{
		(*new_process).thread_info.filename[point] = filename[point];
	}
	/*初始化新进程的内核栈*/
	(*new_process).thread_info.esp0 = Creat_process_init_stack(new_cr3);
	/*将新进程PCB加入链表中*/
	(*new_process).thread_info.next_thread_union = (*thread_union_point).thread_info.next_thread_union;
	(*thread_union_point).thread_info.next_thread_union = new_process;
}

void init_vmac(void)
{
	printk("in init_vmac");
	file_open((*thread_union_point).thread_info.filename,0x10000000);
	struct header (*header);
	header = (struct header *) (256 MB);
	if ((*header).flag[0] == 'G' &&
		(*header).flag[1] == 'B' &&
		(*header).flag[2] == 'O' &&
		(*header).flag[3] == 'S')
	{
		printk("File is right.");
	}else{
		printk("File is right.");
	}
	io_hlt();
}

u32 get_tid(void)
{
	return (*thread_union_point).thread_info.thread_id;
}

u32 get_ppid(void)
{
	return (*thread_union_point).thread_info.ppid;
}

u32 get_pid(void)
{
	return (*thread_union_point).thread_info.pid;
}

void *creat_empty_process(void)
{
	return kmalloc(sizeof(union thread_union));
}
