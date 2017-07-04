#include "../../../include/HAL/x86/function.h"
#include "../../../include/HAL/x86/trap.h"
#include "../../../include/address.h"
#include "../../../include/types.h"

void init_trap(void)
{
	IDT_len = 256;
	IDT_size = IDT_len * 8;
	IDT_addr = (u32 *) kmalloc(IDT_size);
	write_IDTR((u32)IDT_addr, IDT_size - 1);
	clean_IDT();
	init_trap_of_processor();
}

void init_trap_of_processor(void)
{
	creat_IDT(0, code_0_selector, (u32)(&int_DE), interrupt_gate + IDT_32 + IDT_DPL_0 + IDT_P);
	creat_IDT(3, code_0_selector, (u32)(&int_BP), interrupt_gate + IDT_32 + IDT_DPL_0 + IDT_P);
	creat_IDT(4, code_0_selector, (u32)(&int_OF), interrupt_gate + IDT_32 + IDT_DPL_0 + IDT_P);
	creat_IDT(6, code_0_selector, (u32)(&int_UD), interrupt_gate + IDT_32 + IDT_DPL_0 + IDT_P);
	creat_IDT(8, code_0_selector, (u32)(&int_DF), interrupt_gate + IDT_32 + IDT_DPL_0 + IDT_P);
	creat_IDT(10, code_0_selector, (u32)(&int_TS), interrupt_gate + IDT_32 + IDT_DPL_0 + IDT_P);
	creat_IDT(13, code_0_selector, (u32)(&int_GP), interrupt_gate + IDT_32 + IDT_DPL_0 + IDT_P);
	creat_IDT(14, code_0_selector, (u32)(&int_PF), interrupt_gate + IDT_32 + IDT_DPL_0 + IDT_P);
}

/*以下为x86处理器硬件中断*/

void int_Divide_error(void)
{
	color(0xff0000);
	printk("Divide error!!!");
	io_hlt();
}

void int_Break_point(void)
{
	color(0xff0000);
	printk("Break point!!!");
	io_hlt();
}

void int_Over_flow(void)
{
	color(0xff0000);
	printk("Over flow!!!");
	io_hlt();
}

void int_Un_define(void)
{
	color(0xff0000);
	printk("Undefine!!!");
	io_hlt();
}

void int_Double_fault(void)
{
	color(0xff0000);
	printk("Double fault!!!");
	io_hlt();
}

void int_Invalid_TSS(void)
{
	color(0xff0000);
	printk("Invalid TSS!!!");
	io_hlt();
}

void int_General_protection(u32 error_code)
{
	color(0xff0000);
	printk("General protection interrupt:error code:0x%X", error_code);
}
