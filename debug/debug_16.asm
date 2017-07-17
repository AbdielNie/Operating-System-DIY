	jmp		debug_16.end
;debug_16功能宏定义
;断点
%macro breakpoint_16 0
	call	debug_16.breakpoint
%endmacro
;输出4byte十六进制数
%macro print_hex32_16 1
	push	dword %1
	call	debug_16.print_hex32
%endmacro
;输出2Byte十六进制数
%macro print_hex16_16 1
	push	word %1
	call	debug_16.print_hex16
%endmacro
;2Byte十六进制转字符串
%macro hex16_to_str_16 1
	push	word %1
	call	debug_16.hex16_to_str
%endmacro
;字符串打印
%macro print_16 1
	push	word %1
	call	debug_16.print
%endmacro
;键盘上的一些特殊键
	NUL		equ	00		;空字符
	LF		equ	10		;换行键
	CR		equ	13		;回车键
	space	equ	32		;空格
	
debug_16:
.breakpoint:
	push	ax
	pushf
	print_16	.breakpoint_str
	xor		ah,ah
	int		16h
	popf
	pop		ax
	ret
.breakpoint_str:
	db		"There is a breakpoint,Please Press any key to continue.",LF,CR,NUL
	
;32位输出值
.print_hex32:
	push	bp
	mov		bp,sp
	push	edx
	push	eax
	pushf
	mov		edx,[bp+4]
	hex16_to_str_16	dx
	mov		[cs:.print_hex32_value+4],eax
	shr		edx,16
	hex16_to_str_16	dx
	mov		[cs:.print_hex32_value],eax
	print_16	.print_hex32_str
	xor		ah,ah
	int		16h
	popf
	pop		eax
	pop		edx
	pop		bp
	ret		4
.print_hex32_str:
	db		"The program has been pause.",LF,CR
	db		"Value:0x"
.print_hex32_value:
	db		"        .",LF,CR
	db		"Press any key to continue.",LF,CR,NUL
	
;16位输出值
.print_hex16:
	push	bp
	mov		bp,sp
	pushad
	hex16_to_str_16	[bp+4]
	mov		dword[cs:.print_hex16_value],eax
	print_16	.print_hex16_str
	xor		ah,ah
	int		16h
	popad
	pop		bp
	ret		2
.print_hex16_str:
	db		"The program has been pause.",LF,CR
	db		"Value:0x"
.print_hex16_value:
	db		"    .",LF,CR
	db		"Press any key to continue.",LF,CR,NUL

;2Byte的十六进制转字符串
.hex16_to_str:
	push	bp
	mov		bp,sp
	push	cx
	push	dx
	mov		cx,4
	mov		dx,[bp+4]
.hex16_to_str_loop:
	push	dx
	and		dx,0xf
	cmp		dl,9
	jna		.hex16_to_str_dec
	add		dl,0x37
	jmp		.hex16_to_str_save
.hex16_to_str_dec:
	add		dl,0x30
.hex16_to_str_save:
	shl		eax,8
	mov		al,dl
	pop		dx
	shr		dx,4
	loop	.hex16_to_str_loop
	pop		dx
	pop		cx
	pop		bp
	ret		2
;输出信息
.print:
	push	bp
	mov		bp,sp
	pushad
	mov		si,[bp+4]
	mov		ah,0x0e
.print_loop:
	mov		al,[cs:si]
	cmp		al,NUL
	jz		.print_end
	int		10h
	inc		si
	jmp		.print_loop
.print_end:
	popad
	pop		bp
	ret		2
.end:
