;全局变量
extern	thread_union_point
extern	code_0_selector
extern	creat_thread_id
;全局函数
extern	printk
extern	get_tid
extern	creat_empty_process
extern	init_vmac
global	Creat_process_init_stack

THREAD_SIZE	equ	8192



;代码区
[section .text]
[bits 32]
;Warning:能自由使用的寄存器只有EAX\ECX\EDX
Creat_process_init_stack:
	;保存堆栈指针
	mov		edx,esp
	;堆栈指针指向新的PCB
	mov		esp,[esp+4]
	add		esp,THREAD_SIZE-1
	;压入数据
	pushfd
	push	dword[code_0_selector]
	push	init_vmac
	pushad
	push	ds
	push	es
	push	fs
	push	gs
	;返回值
	mov		eax,esp
	mov		esp,edx
	ret
	