#include "../include/HAL/x86/function.h"
#include "../include/HAL/x86/trap.h"
#include "../include/fat32.h"
#include "../include/fat32.h"
#include "../include/8259.h"
#include "../include/process.h"
#include "../include/video.h"
#include "../include/GUI.h"
#include "../include/main.h"
#include "../include/types.h"

/*内核起始函数*/
void kernel_start(void)
{
	init_arch();/*该函数在HAL中*/
	init_memory();
	init_graph();
	init_GUI();
	init_shell();
	//init_hdd();
	//init_FAT32();
	/*加载文件*/
	//load_BACKDROP_PIC();
	//load_COPR();
	/*测试C++函数*/
	//test_C_plus_plus();
	init_trap();
	init_8259();
	init_syscalls();
	//init_process();
	init_keyboard();
}

/*内核主函数*/
void main(void)
{
	printk("main();");
	/*加载GUI*/
	do_exec("GUI.BIN");
	//io_hlt();
}

/*加载版权信息*/
void load_COPR(void)
{
	u32 COPR_buffer;
	file_info COPR_info;
	COPR_buffer = kmalloc(COPR_info.size);
	file_open("COPR.TXT", COPR_buffer);
	printk(COPR_buffer);
	kfree(COPR_buffer, COPR_info.size);
}

/*加载图片测试*/
void load_BACKDROP_PIC(void)
{
	/*initialization picture layer*/
	struct struct_layer *picture_layer;
	picture_layer = GUI_layer_alloc(&layer_root);
	(*picture_layer).visiable = true;
	GUI_set_position(picture_layer, 0, 0);
	
	/*notice:There are use immediately number to the function,
	 *They will be affect support in different VGA mode
	 */
	
	GUI_set_resolution(picture_layer, 800, 600);
	/*试加载BACKDROP.PIC*/
	file_open("BACKDROP.PIC", (u32) (*picture_layer).buf);//BACKDROP_PIC_point
	GUI_refresh(&layer_root);
	refresh_scr((unsigned char *) layer_root.buffer);
}
