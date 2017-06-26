
;全局变量
THREAD_SIZE	equ	8192		;与_start、processs.h中一致
extern	kernel_thread
extern	thread_union_point
extern	printk
extern	debug
extern	code_0_selector
extern	creat_process_id
;全局函数
extern	creat_empty_process		;创建空进程表项函数
extern	copy_pdt				;复制页目录表函数
global	do_fork					;执行fork函数
global	page_test					;执行fork函数



;代码区
[section .text]
[bits 32]
;Warning:能自由使用的寄存器只有EAX\ECX\EDX
do_fork:
	;模拟中断
	pushfd
	push	dword[code_0_selector]
	push	dword .ret
	pushad
	push	ds
	push	es
	push	fs
	push	gs
	;换上内核数据段
	mov		ax,ss
	mov		ds,ax
	mov		es,ax
	;创建一个新PCB(eax=新进程PCB首地址)
	call	creat_empty_process
	;数据指针指向当前PCB和新进程的PCB
	mov		esi,[thread_union_point]
	mov		edi,eax
	;保存esp0
	mov		dword[esi+4],esp
	;拷贝PCB
	xor		ebx,ebx
	mov		ecx,THREAD_SIZE/4
.loop:
	mov		edx,[esi+ebx]
	mov		[edi+ebx],edx
	add		ebx,4
	loop	.loop
	;重定向新进程的thread_info中的esp0
	mov		edx,[edi+4]
	sub		edx,esi
	add		edx,edi
	mov		[edi+4],edx
	;填充新PCB中间需要填充的东西
	;填充父进程id
	mov		eax,[esi+16]
	mov		[edi+20],eax
	;给子进程分配id
	mov		eax,[creat_process_id]
	mov		[edi+16],eax
	mov		[ret_arg],eax
	inc		dword[creat_process_id]
	;将新进程添加到链表里面
	;先将新进程的链表指针指向父进程指向的下一进程
	mov		eax,[esi+8]
	mov		[edi+8],eax
	;再将父进程的下一进程指针指向新进程
	mov		[esi+8],edi
	;父进程返回
	pop		gs
	pop		fs
	pop		es
	pop		ds
	popad
	iret
.ret:
	mov		eax,[ret_arg]
	mov		dword[ret_arg],0x00
	ret

[section .data]
ret_arg		dd	0x00