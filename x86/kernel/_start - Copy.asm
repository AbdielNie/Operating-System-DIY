%include	"arch/x86/include/address.inc"
%include	"arch/x86/include/debug/debug_16.inc"

;全局变量
;全局函数
extern	main
extern	kernel_thread
global	_start

THREAD_SIZE	equ	8192

;代码区
[section .text]
;Warning:能自由使用的寄存器只有EAX\ECX\EDX
[bits 16]
_start:
	cli
	;初始化段寄存器
	mov		ax,cs
	mov		ds,ax
	mov		es,ax
	mov		ss,ax
	mov		sp,$$-1
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
	;暂时不加载GDT
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
[bits 32]
inti_reg:
	mov		eax,0x10
	mov		ds,Eax
	mov		es,ax
	mov		fs,ax
	mov		gs,ax
	mov		ss,ax
	;初始化堆栈指针指向内核栈
	mov		esp,kernel_thread + THREAD_SIZE - 1
	call	main
.halt:
	hlt
	jmp		.halt



;数据区
[section .data]

string:
	.version	db	"Explorer 0.01",LF,CR,NUL
