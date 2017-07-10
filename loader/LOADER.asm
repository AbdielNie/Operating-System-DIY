	org		0x10000			;由boot加载至0x10000
	%include	"include/address.asm"
	%include	"debug/debug_16.asm"
	jmp		entry_16
	times	256	db	0
	stack_top	equ	$
[bits 16]
entry_16:
	cli
	;初始化段寄存器
	mov		ax,cs
	mov		ds,ax
	mov		es,ax
	mov		ss,ax
	mov		sp,stack_top
main16:
	;清屏
	call	clean
	call	reset_cursor
	;显示内核名称及版本
	print_16	string.version
	;获得内存信息
	call	get_memory_info
	;初始化为800*600*24bit分辨率模式
	call	set_screen
	;初始化保护模式
	jmp		enter_protect_mode
	
;设置显示模式
set_screen:
	mov		ax,0x4F02
	mov		bx,0x4115		;800*600*24bit
	int		0x10
	ret

;清屏
clean:
	push	ds
	mov		ax,0xb800
	mov		ds,ax
	xor		si,si
	;循环次数
	mov		cx,80*25*2/4
.loop:
	;全部清零
	mov		dword[ds:si],0x07000700
	add		si,4
	loop	clean.loop
	pop		ds
	ret
	
;重置光标位置
reset_cursor:
	mov		ah,2
	mov		bh,0
	mov		dh,0
	mov		dl,0
	int		10h
	ret
	
get_memory_info:
	pushad
	push	es
	push	ds
	pushf
.clean:
	;清空低64KB
	mov		ax,mem_map.segment
	mov		ds,ax
	xor		si,si
	mov		cx,65536/4
.low_loop:
	mov		dword[ds:si],0x00
	add		si,4
	loop	.low_loop
	;清空高64KB
	mov		ax,mem_map.segment+0x1000
	mov		ds,ax
	xor		si,si
	mov		cx,65536/4
.high_loop:
	mov		dword[ds:si],0x00
	add		si,4
	loop	.high_loop
.get_info:
	;BIOS入口参数
	mov		ax,cs
	mov		es,ax
	mov		di,.ards_BaseAddrLow
	xor		ebx,ebx
	mov		ecx,20
	mov		edx,0534D4150h
	;ds:si指向内存分布区间表
	mov		si,mem_map.segment
	mov		ds,si
	mov		si,mem_map.offset
;循环读取内存信息
.loop:
	mov		eax,0e820h
	int		15h
;判断读取到的段起始地址是否在4GB以下
.cmp_low4GB:
	cmp		dword[cs:.ards_BaseAddrHigh],0x00
	jnz		.cmp_end
;判断读取到的段是否在低1MB以内
.cmp_low1MB:
	mov		eax,[cs:.ards_BaseAddrLow]
	add		eax,[cs:.ards_LengthLow]
	cmp		eax,0x100000
	jna		.cmp_end
	cmp		dword[cs:.ards_BaseAddrLow],0x100000
	ja		.cmp_avaliable
	mov		dword[cs:.ards_BaseAddrLow],0x100000
;判断被读到的段是否是可用的
.cmp_avaliable:
	cmp		dword[cs:.ards_Type],1
	jnz		.cmp_end
	mov		eax,[cs:.ards_BaseAddrLow]
	mov		[ds:si],eax
	add		eax,[cs:.ards_LengthLow]
	mov		[ds:si+4],eax
	add		si,8
.cmp_end:
	cmp		ebx,0x00
	jnz		.loop
	popf
	pop		ds
	pop		es
	popad
	ret
	
.ards_BaseAddrLow	dd	0x0
.ards_BaseAddrHigh	dd	0x0
.ards_LengthLow		dd	0x0
.ards_LengthHigh	dd	0x0
.ards_Type			dd	0x0
	
;进入保护模式
enter_protect_mode:
	;加载GDT
	lgdt	[cs:gdt_size]
	;打开A20地址总线
	in		al,0x92
	or		al,0000_0010B
	out		0x92,al
	;CR0的PE位置1
	mov		eax,cr0
	or		eax,1
	mov		cr0,eax
	;远跳转,清空流水线
	jmp		dword 0x08:inti_reg
	
gdt:
	;0描述符
	dd		0x00000000
	dd		0x00000000
	;1描述符(4GB代码段描述符)
	dd		0x0000ffff
	dd		0x00cf9A00
	;2描述符(4GB数据段描述符)
	dd		0x0000ffff
	dd		0x00cf9200
	;3描述符(用户代码段描述符)
	dd		0x0000ffff
	dd		0x00CfFe00
	;4描述符(用户数据段描述符)
	dd		0x0000ffff
	dd		0x00CfF200
	gdt_size		dw	gdt_size-gdt-1		;GDT的长度
	gdt_base		dd	gdt					;GDT的物理地址
	
string:
	.version	db	"Explorer 0.01",LF,CR,NUL
[bits 32]
inti_reg:
	mov		eax,0x10
	mov		ds,Eax
	mov		es,ax
	mov		fs,ax
	mov		gs,ax
	mov		ss,ax
	mov		esp,stack_top
	jmp		_start	
	times	4096-($-$$)	db	0
_start:
	
