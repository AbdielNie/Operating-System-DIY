;Copyright 2013-2014 by Explorer Developer.
;made by 迷彩红星<1@GhostBirdOS.org>
;Explorer 起始函数
;Explorer 0.01/arch/kernel/_start.asm
;version:Alpha
;7/9/2014 8:25 AM

;全局变量
;全局函数
extern	io_hlt
extern	kernel_start
extern	main
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
	call	main
	call	io_hlt



;数据区
[section .data]

