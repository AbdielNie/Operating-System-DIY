/*
 *Copyright 2013-2014 by 2013-2014 by Explorer OS Developer. All rights reserved.
 *made by �Բʺ���<1@GhostBirdOS.org>
 *Explorer 0.01 x86ƽ̨Ӳ�������ͷ�ļ�
 *Explorer/Kernel/include/HAL/x86/function.h
 *7/14/2014 1:49 PM
 */

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
//fun_c.c����
void init_arch(void);
void inti_GDT(void);
void goto_paging(u32 pdt_addr);

//fun_asm.asm����
//ȫ��������������
#define GDT_G		0x800000
#define GDT_P		0x8000
#define GDT_DPL_0	0x00
#define GDT_DPL_1	0x2000
#define GDT_DPL_2	0x4000
#define GDT_DPL_3	0x6000
/*ע��:��Ϊ�ɶ��Ĵ����*/
#define GDT_code_32_conforming		0x401E00
#define GDT_code_32_non_conforming	0x401A00
/*Ϊ���ϵ����ݶΣ����µ����ݶ��з��գ�����ʹ��*/
#define GDT_data_32 0x401200
/*ϵͳ��*/
#define GDT_TSS_data 0x900
//��ʼ���μĴ�������
void init_seg_reg(u16 selector);
//��������Ĵ�����������
void write_IDTR(u32 base, u16 size);
void write_TR(u16 select);
void write_GDTR(u32 base, u16 size);
//GDT��������
void clean_GDT(void);
u16 creat_GDT(u32 base_addr, u32 length, u32 attribute);
//IDT��������
void clean_IDT(void);
void creat_IDT(u32 number, u32 selector, u32 offset, u32 attribute);
//���ƼĴ�����д
u32 read_cr0(void);
void write_CR0(u32 cr0);
u32 read_cr3(void);
void write_CR3(u32 cr0);
//�����С�ڴ��д����
void write_mem24(u32 addr, u32 data);


#endif

