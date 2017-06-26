extern	printk
global	do_sys_calls



[section .text]
[bits 32]

;更好的实现方式应当是根据eax的功能号从功能表中跳入相应的函数位置执行
;为了方便实行，目前仅仅判断中断号执行（这个方法不适合大量调用）

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
	
