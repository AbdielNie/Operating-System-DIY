#include "../include/syscalls.h"
#include "../include/HAL/x86/trap.h"
#include "../include/HAL/x86/function.h"

void init_syscalls(void)
{
	creat_IDT(0xff, code_0_selector, (u32)&do_sys_calls, trap_gate + IDT_32 + IDT_DPL_3 + IDT_P);
}