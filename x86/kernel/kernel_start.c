#include "../include/kernel_start.h"
#include "../include/CPU.h"

void kernel_start(void)
{
	init_arch();
	init_memory();
	init_trap();
	init_dev();
	init_graph();
	init_shell();
	output_CPU_info();
}

/*initialization device which we need*/
void init_dev(void)
{
	init_CPU();
	init_PIC();
	init_PIT();
}

void output_CPU_info(void)
{
	printk("CPU OME:%s\n", &CPU_OME);
	printk("CPUID support in MAX:%X\n",CPU_MAXID);
	printk("extended CPUID support in MAX:%X\n",CPU_EMAXID);
}
