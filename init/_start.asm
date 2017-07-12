;全局变量
;全局函数
extern	io_hlt
extern	kernel_start
extern	kernel_thread
global	_start

THREAD_SIZE	equ	8192

;代码区
[section .text]
[bits 32]
;Warning:能自由使用的寄存器只有EAX\ECX\EDX
_start:
	;初始化堆栈指针指向内核栈
	mov		esp,kernel_thread + THREAD_SIZE - 1
	call	kernel_start
	call	io_hlt



;数据区
[section .data]

