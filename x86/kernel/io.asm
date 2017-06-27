;输入输出函数
global	io_hlt,io_cli,io_sti
global	io_read_eflags,io_write_eflags
global	io_in8,io_in16,io_in32
global	io_out8,io_out16,io_out32

;代码区
[section .text]
[bits 32]

;输入输出函数
io_hlt:
	hlt
	jmp		io_hlt
io_cli:
	cli
	ret
io_sti:
	sti
	ret
io_read_eflags:
	pushfd
	pop		eax
	ret
io_write_eflags:
	mov		eax,[esp+4]
	push	eax
	popfd
	ret
io_in8:
	mov		edx,[esp+4]
	xor		eax,eax
	in		al,dx
	ret
io_in16:
	mov		edx,[esp+4]
	xor		eax,eax
	in		ax,dx
	ret
io_in32:
	mov		edx,[esp+4]
	in		eax,dx
	ret
io_out8:
	mov		edx,[esp+4]
	mov		al,[esp+8]
	out		dx,al
	ret
io_out16:
	mov		edx,[esp+4]
	mov		eax,[esp+8]
	out		dx,ax
	ret
io_out32:
	mov		edx,[esp+4]
	mov		eax,[esp+8]
	out		dx,eax
	ret