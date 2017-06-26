#include "../include/process.h"
#include "../include/types.h"
#include "../include/address.h"
#include "../include/memory.h"

void do_exec(u8 *filename)
{
	u32 *new_cr3, *old_cr3;
	/*先创建新页目录表*/
	new_cr3 = kmalloc(4 KB);
	if (creat_pdt(new_cr3) != 0)
	{
		color(0x00ff00);
		printk("execut the new program error!");
		io_hlt();
	}
	/*指向新页目录表*/
	old_cr3 = (*thread_union_point).thread_info.cr3;
	(*thread_union_point).thread_info.cr3 = new_cr3;
	write_CR3(new_cr3);
	/*释放旧页目录表*/
	/*未完成*/
	kfree((u32)old_cr3, 4 KB);
	/*加载新程序*/
	file_open(filename, 256 MB);
	/*判断新程序格式是否正确*/
	struct header (*header);
	header = (struct header *) (256 MB);
	if ((*header).flag[0] == 'G' &&
		(*header).flag[1] == 'B' &&
		(*header).flag[2] == 'O' &&
		(*header).flag[3] == 'S')
	{
		init_exe_environment();/*通过这个函数去执行应用程序*/
	}else{
		printk("This isn't the executable file.\n");
	}
	io_hlt();
}