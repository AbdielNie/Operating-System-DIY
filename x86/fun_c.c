#include "../../include/HAL/x86/function.h"
#include "../../include/address.h"
#include "../../include/types.h"

//结构初始化
void init_arch(void)
{
	/*准备GDT表*/
	write_GDTR(GDT_addr, GDT_size - 1);
	clean_GDT();
	/*准备数据段和代码段*/
	code_0_selector = creat_GDT(0, 0xfffff, GDT_G + GDT_P + GDT_DPL_0 + GDT_code_32_non_conforming);
	code_3_selector = creat_GDT(0, 0xfffff, GDT_G + GDT_P + GDT_DPL_3 + GDT_code_32_conforming);
	data_0_selector = creat_GDT(0, 0xfffff, GDT_G + GDT_P + GDT_DPL_0 + GDT_data_32);
	data_3_selector = creat_GDT(0, 0xfffff, GDT_G + GDT_P + GDT_DPL_3 + GDT_data_32);
	init_seg_reg(data_0_selector);
	/*准备TSS(真心不该有TSS):-(*/
	TSS.ss0 = data_0_selector;
	TSS_selector = creat_GDT(((u32)&TSS), sizeof(TSS), GDT_P + GDT_DPL_0 + GDT_TSS_data);
}

//进入分页模式
void goto_paging(u32 pdt_addr)
{
	write_CR3(pdt_addr);
	write_CR0(read_CR0() | 0x80000000);
}
