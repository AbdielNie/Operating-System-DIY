;全局变量
extern	code_3_selector
extern	data_3_selector
;全局函数
global	restart

;代码区
[section .text]
[bits 32]
;Warning:能自由使用的寄存器只有EAX\ECX\EDX
restart:
	mov		edx,esp
	mov		ecx,[data_3_selector]
	or		ecx,3
	push	ecx
	push	edx
	pushfd
	mov		eax,[code_3_selector]
	or		eax,3
	push	eax
	push	.next
	iretd
.next:
	jmp		$
	