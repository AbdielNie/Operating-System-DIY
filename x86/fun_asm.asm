%include	"include/address.asm"
%include	"include/HAL/x86/function.asm"

;全局变量

;全局函数
;TSC函数
global	read_tsc
;初始化段寄存器函数
global	init_seg_reg
;描述符寄存器操作函数
global	write_IDTR
global	write_TR
global	write_GDTR
;IDT操作函数
global	clean_IDT
global	creat_IDT
;GDT操作函数
global	clean_GDT
global	creat_GDT
;控制寄存器读写
global	read_CR0,write_CR0
global	read_CR2,write_CR2
global	read_CR3,write_CR3
;特殊大小内存读写函数
global	write_mem24

;调用宏
;void write_IDTR(u32 IDTR.base, u16 IDTR.size)
%macro call_write_IDTR 2
	push	word %2
	push	dword %1
	call	write_IDTR
	add		esp,6
%endmacro
;void write_GDTR(u32 GDTR.base, u16 GDTR.size)
%macro call_write_GDTR 2
	push	word %2
	push	dword %1
	call	write_GDTR
	add		esp,6
%endmacro
;void write_TR(u16 selector)
%macro call_write_TR 1
	push	word %1
	call	write_TR
	add		esp,2
%endmacro
;u16 creat_GDT(u32 segment_base, u32 limit, u32 attribute)
%macro call_creat_GDT 3
	push	dword %3
	push	dword %2
	push	dword %1
	call	creat_GDT
	add		esp,12
%endmacro
;void creat_IDT(u32 number, u32 selector, u32 offset, u32 attribute)
%macro call_creat_IDT 4
	push	dword %4
	push	dword %3
	push	dword %2
	push	dword %1
	call	creat_IDT
	add		esp,16
%endmacro
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


	
;代码区
[section .text]
[bits 32]
;Warning:能自由使用的寄存器只有EAX\ECX\EDX	
;TSC函数
read_tsc:
	rdtsc
	mov		ecx,[esp+4]
	mov		[ecx],eax
	mov		[ecx+4],edx

;初始化段寄存器函数
init_seg_reg:
	mov		ax,[esp+4]
	mov		ds,ax
	mov		es,ax
	mov		fs,ax
	mov		gs,ax
	mov		ss,ax
	ret

;描述符寄存器操作函数
write_IDTR:
;void write_IDT(u32 base, u16 size)
	mov		eax,[esp+4]
	mov		[IDTR.base],eax
	mov		ax,[esp+8]
	mov		[IDTR.size],ax
	lidt	[cs:IDTR]		;加载IDTR
	ret
write_TR:
;void write_TR(u16 select)
	mov		ax,[esp+4]
	ltr		ax
	ret
write_GDTR:
;void write_GDTR(u32 base, u16 size)
	mov		eax,[esp+4]
	mov		[GDTR.base],eax
	mov		ax,[esp+8]
	mov		[GDTR.size],ax
	lgdt	[cs:GDTR]		;加载GDTR
	ret

;IDT操作函数
clean_IDT:
;void clean_IDT(void)
	mov		edx,[IDTR.base]
	mov		ecx,IDTR.size
	shr		ecx,2
.loop:
	mov		dword[edx],0x0
	add		edx,4
	loop	.loop
	ret
creat_IDT:
;void creat_IDT(u32 number, u32 selector, u32 offset, u32 attribute)
	xor		eax,eax
	mov		al,[esp+4]	;number参数
	shl		eax,3		;相当于乘8
	add		eax,[IDTR.base];加上addr的起始地址
	mov		dx,[esp+8]	;selector参数
	mov		[eax+2],dx
	mov		edx,[esp+12]	;offset参数
	mov		[eax],dx	;dx=offset低16位
	shr		edx,16
	mov		[eax+6],dx	;dx=offset高16位
	mov		word[eax+4],0;清空属性区域
	mov		edx,[esp+16];attribute参数
	add		[eax+4],edx	;加上属性
	ret

;GDT操作函数
clean_GDT:
;void clean_GDT(void)
	mov		edx,[GDTR.base]
	mov		ecx,GDTR.size
	shr		ecx,2
.loop:
	mov		dword[edx],0x0
	add		edx,4
	loop	.loop
	ret
creat_GDT:
;u16 creat_GDT(u32 segment_base, u32 limit, u32 attribute)
	push	ebp
	mov		ebp,esp
	push	esi
	;表基地址
	mov		esi,[GDTR.base]
.loop:
	;跳过空描述符以及循环查找功能
	add		esi,8
	;判断该GDT表项是否是8字节的0
	cmp		dword[esi],0x00
	jnz		.loop
	cmp		dword[esi+4],0x00
	jnz		.loop
	;将段基址放置到GDT中
	mov		eax,[ebp+8]
	mov		[esi+2],ax
	shr		eax,16
	mov		[esi+4],al
	mov		[esi+7],ah
	;将界限放置到GDT
	mov		eax,[ebp+12]
	mov		[esi],ax
	;震荡eax,保证高12位为0
	shl		eax,12
	shr		eax,12+16
	mov		[esi+6],al
	;将属性加入表项中
	mov		eax,[ebp+16]
	add		[esi+4],eax
	;计算出select value
	mov		eax,esi
	sub		eax,[GDTR.base]
	pop		esi
	pop		ebp
	ret
	
;控制寄存器的读写
read_CR0:
	mov		eax,cr0
	ret
read_CR2:
	mov		eax,cr2
	ret
read_CR3:
	mov		eax,cr3
	ret
write_CR0:
	mov		eax,[esp+4]
	mov		cr0,eax
	ret
write_CR2:
	mov		eax,[esp+4]
	mov		cr2,eax
	ret
write_CR3:
	mov		eax,[esp+4]
	mov		cr3,eax
	ret


	
write_mem24:
	mov		edx,[esp+8]
	mov		ecx,[esp+4]
	mov		[ecx],dx
	shr		dx,16
	mov		[ecx+2],dl
	ret
	
;数据区
[section .data]

;GDTR
GDTR:
	.size		dw	0			;GDT的长度
	.base		dd	0			;GDT的物理地址
;IDTR
IDTR:
	.size		dw	0			;IDT的长度
	.base		dd	0			;IDT的物理地址
