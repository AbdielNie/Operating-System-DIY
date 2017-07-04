;全局函数
extern	int_Divide_error
extern	int_Break_point
extern	int_Over_flow
extern	int_Double_fault
extern	int_Un_define
extern	int_Invalid_TSS
extern	int_General_protection
extern	do_page_fault

global	int_DE
global	int_BP
global	int_OF
global	int_DF
global	int_UD
global	int_TS
global	int_GP
global	int_PF



;代码区
[section .text]
[bits 32]

int_DE:
	call	int_Divide_error
	iretd

int_BP:
	call	int_Break_point
	iretd

int_OF:
	call	int_Over_flow
	iretd

int_DF:
	call	int_Double_fault
	iretd
	
int_UD:
	call	int_Un_define
	iretd

int_TS:
	call	int_Invalid_TSS
	iretd
	
int_GP:
	call	int_General_protection
	add		esp,4
	hlt
	iretd
	
int_PF:
	pushad
	push	dword[esp+32]
	call	do_page_fault
	add		esp,4
	popad
	add		esp,4
	iretd
