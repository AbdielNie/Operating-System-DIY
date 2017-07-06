;全局函数
extern	printk
global	do_sys_calls



[section .text]
[bits 32]


do_sys_calls:
	cmp		eax,0x1
	jmp		do_printf
	iretd

;printf的执行函数:eax=1;esi=字符串首地址
do_printf:
	push	esi
	call	printk
	add		esp,4
	iretd
	
