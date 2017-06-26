;全局函数
global	do_creat_thread



;代码区
[section .text]
[bits 32]
;Warning:能自由使用的寄存器只有EAX\ECX\EDX
;do_creat_thread(void *point)
;未完成
do_creat_thread:
	;创建一个新PCB(eax=新进程PCB首地址)
	;call	creat_empty_process
	;数据指针指向PCB
	;mov		ecx,[thread_union_point]
	;获取cr3
	mov		edx,[esi+12]
	ret
