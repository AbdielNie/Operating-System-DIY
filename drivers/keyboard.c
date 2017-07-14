#include "../include/8259.h"
#include "../include/HAL/x86/trap.h"
void init_keyboard(void)
{
	/*先创建中断*/
	extern	int_keyboard;
	creat_IDT(0x21, 8, (&int_keyboard), interrupt_gate + IDT_32 + IDT_DPL_0 + IDT_P);
	/*启用8259*/
	open_8259(1);
}

void int_keyboard_display(u32 code)
{
	//draw_square(0, 550, 800, 50, code * code * code * code);
	printk("int Keyboard!\n");
}
