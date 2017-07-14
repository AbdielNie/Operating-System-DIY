;Copyright 2013-2014 by Explorer Developer.
;made by 迷彩红星<1@GhostBirdOS.org>
;Explorer 8259\定时器支持程序汇编文件
;ExplorerOS/Kernel/include/timer_asm.asm
;version:Alpha
;7/28/2014 4:26 PM

;全局变量
extern	thread_union_point
;全局函数
extern	int_timer_display
global	int_timer



;代码区
[section .text]
[bits 32]
;时钟中断处理程序
int_timer:
	;保存上下文
	pushad
	push	ds
	push	es
	push	fs
	push	gs
	;换上内核态的数据段
	mov		dx,ss
	mov		ds,dx
	mov		es,dx
	;处理时钟函数
	call	int_timer_display
	;EOI
	mov		al,20h
	out		20h,al
	out		0xa0,al
	;数据指针指向PCB
	mov		esi,[thread_union_point]
	;保存esp0
	mov		[esi+4],esp
	;执行完时钟中断处理程序
	;判断count有没有用完
	cmp		dword[esi],0
	jnz		.ret
	;切换当前的PCB
	mov		esi,[esi+8]
	mov		[thread_union_point],esi
	;切换cr3
	mov		eax,[esi+12]
	mov		cr3,eax
	;分配时钟片
	mov		eax,[esi+24]
	mov		[esi],eax	
	;取得当前的PCB的ESP0
	mov		esp,[esi+4]
;返回
.ret:
	;计数递减
	dec		dword[esi]
	pop		gs
	pop		fs
	pop		es
	pop		ds
	popad
	iret
	
[section .data]