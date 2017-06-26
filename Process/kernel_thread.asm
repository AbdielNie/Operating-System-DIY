;全局变量
extern	thread_union_point
extern	code_0_selector
extern	creat_thread_id
;全局函数
extern	printk
extern	get_tid
extern	creat_empty_process
global	Creat_kernel_thread
global	do_recycle_thread

THREAD_SIZE	equ	8192



;代码区
[section .text]
[bits 32]
;Warning:能自由使用的寄存器只有EAX\ECX\EDX
;kcreat_thread(void *point)
Creat_kernel_thread:
	call	creat_empty_process
;数据指针指向PCB
	mov		edx,[thread_union_point]
	;eax=新PCB
;拷贝cr3
	mov		ecx,[edx+12]
	mov		[eax+12],ecx
;拷贝pid
	mov		ecx,[edx+16]
	mov		[eax+16],ecx
;拷贝ppid
	mov		ecx,[edx+20]
	mov		[eax+20],ecx
;default_count分别除二，为了防止右移后结果为0，除二后都加一
	shr		dword[edx+24],1
	inc		dword[edx+24]
	mov		ecx,[edx+24]
	mov		[eax+24],ecx
;count设default_count
	mov		[eax],ecx
;分配新的线程id
	mov		ecx,[creat_thread_id]
	mov		[eax+28],ecx
	inc		dword[creat_thread_id]
;获得函数参数
	mov		ecx,[esp+4]
;保存现在的esp0
	mov		[edx+4],esp
;esp指向新PCB的堆栈顶头
	lea		esp,[eax+THREAD_SIZE-1]
	push	do_recycle_thread
	pushfd
	push	dword[code_0_selector]
	push	ecx
	pushad
	push	ds
	push	es
	push	fs
	push	gs
;保存esp0
	mov		[eax+4],esp
;还原esp0
	mov		esp,[edx+4]
;先将新进程的链表指针指向下一进程
	mov		ecx,[edx+8]
	mov		[eax+8],ecx
;再将父进程的指针指向新进程
	mov		[edx+8],eax
	ret
	
do_recycle_thread:
	call	get_tid
	push	eax
	push	thread_end
	call	printk
	add		esp,8
.halt:
	hlt
	jmp		.halt

[section .data]
thread_end	db	"The thread %X is end.",0x0d,0x00