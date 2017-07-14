;中断描述符表属性
%define IDT_P		0x8000
%define IDT_DPL_0	0x00
%define IDT_DPL_1	0x2000
%define IDT_DPL_2	0x4000
%define IDT_DPL_3	0x6000
%define IDT_16		0x00
%define IDT_32		0x800
%define trap_gate		0x700
%define interrupt_gate	0x600
;全局描述符表属性
%define GDT_G 0x800000
%define GDT_P 0x8000
%define GDT_DPL_0 0x00
%define GDT_DPL_1 0x2000
%define GDT_DPL_2 0x4000
%define GDT_DPL_3 0x6000
;注意:都为可读的代码段
%define GDT_code_32_conforming 0x401E00
%define GDT_code_32_non_conforming 0x401A00
;为向上的数据段，向下的数据段有风险，不可使用
%define GDT_data_32 0x200
;系统段
%define GDT_TSS_data 0x900
