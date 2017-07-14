#ifndef FUNCTION_H_
#define FUNCTION_H_

#include "../../types.h"

u32 code_0_selector, data_0_selector, TSS_selector;
u32 code_3_selector, data_3_selector;

struct TSS_32
{
	int backlink, esp0, ss0, esp1, ss1, esp2, ss2, cr3;
	int eip, eflags, eax, ecx, edx, ebx, esp, ebp, esi, edi;
	int es, cs, ss, ds, fs, gs;
	int ldtr, iomap;
}TSS;
//fun_c.c函数
void init_arch(void);
void inti_GDT(void);
void goto_paging(u32 pdt_addr);

//fun_asm.asm函数
//全局描述符表属性
#define GDT_G		0x800000
#define GDT_P		0x8000
#define GDT_DPL_0	0x00
#define GDT_DPL_1	0x2000
#define GDT_DPL_2	0x4000
#define GDT_DPL_3	0x6000
/*注意:都为可读的代码段*/
#define GDT_code_32_conforming		0x401E00
#define GDT_code_32_non_conforming	0x401A00
/*为向上的数据段，向下的数据段有风险，不可使用*/
#define GDT_data_32 0x401200
/*系统段*/
#define GDT_TSS_data 0x900
//初始化段寄存器函数
void init_seg_reg(u16 selector);
//描述符表寄存器操作函数
void write_IDTR(u32 base, u16 size);
void write_TR(u16 select);
void write_GDTR(u32 base, u16 size);
//GDT操作函数
void clean_GDT(void);
u16 creat_GDT(u32 base_addr, u32 length, u32 attribute);
//IDT操作函数
void clean_IDT(void);
void creat_IDT(u32 number, u32 selector, u32 offset, u32 attribute);
//控制寄存器读写
u32 read_cr0(void);
void write_CR0(u32 cr0);
u32 read_cr3(void);
void write_CR3(u32 cr0);
//特殊大小内存读写函数
void write_mem24(u32 addr, u32 data);


#endif

