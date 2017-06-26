
;全局函数
extern	thread_union_point
extern	printk
extern	code_3_selector
extern	data_3_selector
global	init_exe_environment

THREAD_SIZE	equ	8192


;代码区
[section .text]
[bits 32]
;Warning:能自由使用的寄存器只有EAX\ECX\EDX
init_exe_environment:
	mov		esp,[thread_union_point]
	add		esp,THREAD_SIZE-1
	jmp		dword[0x10000000+4]

