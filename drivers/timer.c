
#include "../include/HAL/x86/io.h"
#include "../include/8259.h"
#include "../include/HAL/x86/trap.h"
#include "../include/HAL/x86/function.h"
#include "../include/timer.h"

void init_timer(void)
{
	/*先创建中断*/
	creat_IDT(0x20, code_0_selector, (u32)(&int_timer), interrupt_gate + IDT_32 + IDT_DPL_0 + IDT_P);
	/*初始化频率*/
	init_pit();
	/*启用8259*/
	open_8259(0);
}

void int_timer_display(void)
{
	
}

void init_pit(void)
{
	io_out8(PIT_CTRL, 0x34);
	io_out8(PIT_CNT0, 0x9c);
	io_out8(PIT_CNT0, 0x2e);
	return;
}
