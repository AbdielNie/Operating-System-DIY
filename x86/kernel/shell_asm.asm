;Copyright 2013-2014 by 2013-2014 by Explorer OS Developer. All rights reserved.

;Explorer 0.01  shell的汇编部分
;File name:Explorer\Kernel\shell\fun_asm.asm
;2014.7.14 11:16 PM

;外部函数
extern	put_font
%macro fun_put_font 1
	push	dword %1
	call	put_font
	add		esp,4
%endmacro

;全局函数
global	printk

;宏定义
	NUL		equ	0x00
%macro	fun_display 1
	push	dword %1
	call	display
	add		esp,4
%endmacro

%macro	fun_hex2str32 1
	push	dword %1
	call	hex2str32
	add		esp,4
%endmacro

%macro	fun_hex2str16 1
	push	dword %1
	call	hex2str16
	add		esp,4
%endmacro
	
;代码区
[section .text]
[bits 32]
printk:
	push	ebp
	mov		ebp,esp
	push	esi
	push	eax
	push	ebx
	;获得指向字符串的指针
	mov		esi,[ebp+8]
	;获得指向第二个参数的指针
	mov		ebx,12
.loop:
;判断是否结束、有无"%"
.cmp_0:
	cmp		byte[esi],'%'
	jnz		.output
	;是"%"的处理办法
.cmp_1:
	cmp		byte[esi+1],'X'
	jnz		.cmp_2
	fun_hex2str32	[ebp+ebx]
	fun_display		eax
	add		ebx,4
	add		esi,2
	jmp		.output
.cmp_2:
	cmp		byte[esi+1],'s'
	jnz		.output
	fun_display	[ebp+ebx]
	add		ebx,4
	add		esi,2
;输出
.output:
	cmp		byte[esi],NUL
	jz		.end
	fun_put_font	[esi]
	;指向下一个字符
	inc		esi
	jmp		.loop
.end:
	pop		ebx
	pop		eax
	pop		esi
	pop		ebp
	ret
	
display:
	push	ebp
	mov		ebp,esp
	push	esi
	;获得指向字符串的指针
	mov		esi,[ebp+8]
.loop:
	cmp		byte[esi],NUL
	jz		.end
	fun_put_font	[esi]
	inc		esi
	jmp		.loop
.end:
	pop		esi
	pop		ebp
	ret
	
hex2str32:
	push	ebp
	mov		ebp,esp
	push	edx
	mov		edx,[ebp+8]
	fun_hex2str16	edx
	mov		dword[.buffer+4],eax
	shr		edx,16
	fun_hex2str16	edx
	mov		dword[.buffer],eax
	;把多余0屏蔽掉
	mov		eax,.buffer
.loop:
	cmp		byte[eax],'0'
	jnz		.end
	inc		eax
	jmp		.loop
.end:
	;防止不输出0
	cmp		byte[eax],0x00
	jnz		.end_2
	dec		eax
.end_2:
	pop		edx
	pop		ebp
	ret


hex2str16:
	push	ebp
	mov		ebp,esp
	push	edx
	push	ecx
	mov		ecx,4
	mov		edx,[ebp+8]
.loop:
	push	dx
	and		dx,0xf
	cmp		dl,9
	jna		.dec
	add		dl,0x37
	jmp		.save
.dec:
	add		dl,0x30
.save:
	shl		eax,8
	mov		al,dl
	pop		dx
	shr		dx,4
	loop	.loop
	pop		ecx
	pop		edx
	pop		ebp
	ret
[section .data]
hex2str32.buffer		times	9	db	0