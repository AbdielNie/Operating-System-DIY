
	org  0x7c00
	
	stack_base				equ	07c00h	;
	file_addr_segment		equ	0x1000	;文件被加载到的位�?段地址)
	file_addr_offset		equ	0x0		;文件被加载到的位�?偏移地址)
	RootDirSectors			equ	14		;根目录占用空�?	root_sector				equ	19		;根目录的第一个扇区号
	SectorNoOfFAT1			equ	1		;FAT1 的第一个扇区号 = BPB_RsvdSecCnt
	DeltaSectorNo			equ	17
	
	;下面�?FAT12 磁盘的头
	jmp short boot_start
	nop
	BS_OEMName		DB 'GhosBird'	; OEM String, 必须 8 个字�?	BPB_BytsPerSec	DW 512			; 每扇区字节数
	BPB_SecPerClus	DB 1			; 每簇多少扇区
	BPB_RsvdSecCnt	DW 1			; Boot 记录占用多少扇区
	BPB_NumFATs		DB 2			; 共有多少 FAT �?	BPB_RootEntCnt	DW 224			; 根目录文件数最大�?	BPB_TotSec16	DW 2880			; 逻辑扇区总数
	BPB_Media		DB 0xF0			; 媒体描述�?	BPB_FATSz16		DW 9			; 每FAT扇区�?	BPB_SecPerTrk	DW 18			; 每磁道扇区数
	BPB_NumHeads	DW 2			; 磁头�?面数)
	BPB_HiddSec		DD 0			; 隐藏扇区�?	BPB_TotSec32	DD 0			; 如果 wTotalSectorCount �?0 由这个值记录扇区数
	BS_DrvNum		DB 0			; 中断 13 的驱动器�?	BS_Reserved1	DB 0			; 未使�?	BS_BootSig		DB 29h			; 扩展引导标记 (29h)
	BS_VolID		DD 0			; 卷序列号
	BS_VolLab		DB 'GhostBirdOS'; 卷标, 必须 11 个字�?	BS_FileSysType	DB 'FAT12   '	; 文件系统类型, 必须 8个字�? 

boot_start:	
	mov		ax,cs
	mov		ds,ax
	mov		es,ax
	mov		ss,ax
	mov		sp,stack_base

	;清屏
	mov		ax,0600h
	mov		bx,0700h
	mov		cx,0
	mov		dx,0184fh
	int		10h
	;显示"Booting"
	mov		dh,0
	call	DispStr
	;软驱复位
	xor		ah,ah
	xor		dl,dl
	int		13h
	
	;下面在软盘的根目录寻找文�?	mov		word[read_sector],root_sector
begin_search:
	;判断根目录是否读完，读完表示没有找到文件
	cmp		word[root_sector_num],0
	jz		nofound
	dec		word[root_sector_num]
	mov		ax,file_addr_segment
	mov		es,ax										;es <- file_addr_segment
	mov		bx,file_addr_offset							;bx <- file_addr_offset	于是, es:bx = file_addr_segment:file_addr_offset
	mov		ax,[read_sector]								;ax <- Root Directory 中的�?Sector �?	mov		cl,1
	call	ReadSector

	mov		si,KERNELFileName							;ds:si -> "KERNEL  "
	mov		di,file_addr_offset							;es:di -> file_addr_segment:0100 = file_addr_segment*10h+100
	cld
	mov		dx,10h

;循环次数控制
LABEL_SEARCH_FOR_KERNELBIN:
	cmp		dx,0										;┓循环次数控�?
	jz		next_sector			;┣如果已经读完了一�?Sector,
	dec		dx											;┛就跳到下一�?Sector
	mov		cx,11

;对比文件�?cmp_filenasm:
	cmp		cx,0
	jz		filename_founded
	dec		cx
	lodsb
	cmp		al,byte[es:di]
	jz		LABEL_GO_ON
	;到这里代表文件名匹配不一�?	jmp		filename_different
; 我们要找�?KERNEL
LABEL_GO_ON:
	inc		di
	jmp		cmp_filenasm							;继续循环

;文件名不一�?filename_different:
	and		di,0FFE0h
	add		di,20h
	mov		si,KERNELFileName
	jmp		LABEL_SEARCH_FOR_KERNELBIN

;从下个root扇区开始搜�?next_sector:
	add		word[read_sector],1
	jmp		begin_search

;没有找到文件
nofound:
	mov		dh,2										;"No KERNEL."
	call	DispStr										;显示字符�?	jmp		$											;没有找到KERNEL死循环在这里

;找到文件
filename_founded:									;找到 KERNEL 后便来到这里继续
	mov		ax,RootDirSectors
	and		di,0FFE0h									;di -> 当前条目的开�?	add		di,01Ah										;di -> �?Sector
	mov		cx,word[es:di]
	push	cx											;保存�?Sector �?FAT 中的序号
	add		cx,ax
	add		cx,DeltaSectorNo							;cl <- KERNEL的起始扇区号(0-based)
	mov		ax,file_addr_segment
	mov		es,ax										;es <- file_addr_segment
	mov		bx,file_addr_offset							;bx <- file_addr_offset
	mov		ax,cx										;ax <- Sector �?
;加载文件
loading_file:
	;每读一个扇区就�?Booting"后面打一个点
	push	ax
	push	bx
	mov		ah,0Eh
	mov		ax,0x0e00+'.'
	mov		bl,0Fh
	int		10h
	pop		bx
	pop		ax

	mov		cl, 1
	call	ReadSector
	pop		ax											;取出�?Sector �?FAT 中的序号
	call	GetFATEntry
	cmp		ax,0FFFh
	jz		load_finished
	push	ax											;保存 Sector �?FAT 中的序号
	mov		dx,RootDirSectors
	add		ax,dx
	add		ax,DeltaSectorNo
	add		bx,[BPB_BytsPerSec]
	jmp		loading_file
load_finished:
	;显示"Ready."
	mov		dh,1
	call	DispStr

	;跳转到已经加载的文件�?	jmp		file_addr_segment:file_addr_offset

;变量
	;根目录扇区总数
	root_sector_num		dw	RootDirSectors	;Root Directory 占用的扇区数, 在循环中会递减至零.
	read_sector			dw	0				;要读取的扇区�?	bOdd				db	0				;奇数还是偶数

;============================================================================
;字符�?;----------------------------------------------------------------------------
KERNELFileName		db	"KERNEL     ", 0	; KERNEL 之文件名
; 为简化代�? 下面每个字符串的长度均为 MessageLength
MessageLength		equ	9
BootMessage:		db	"Booting  "; 9字节, 不够则用空格补齐. 序号 0
Message1		db	"Ready.   "; 9字节, 不够则用空格补齐. 序号 1
Message2		db	"No KERNEL"; 9字节, 不够则用空格补齐. 序号 2
;============================================================================


;----------------------------------------------------------------------------
; 函数�? DispStr
;----------------------------------------------------------------------------
; 作用:
;	显示一个字符串, 函数开始时 dh 中应该是字符串序�?0-based)
DispStr:
	mov		ax,MessageLength
	mul		dh
	add		ax,BootMessage
	mov		bp,ax
	mov		ax,ds
	mov		es,ax
	mov		cx,MessageLength
	mov		ax,01301h
	mov		bx,0007h
	mov		dl,0
	int		10h
	ret

;----------------------------------------------------------------------------
; 函数�? ReadSector
;----------------------------------------------------------------------------
; 作用:
;	从第 ax �?Sector 开�? �?cl �?Sector 读入 es:bx �?ReadSector:
	; -----------------------------------------------------------------------
	; 怎样由扇区号求扇区在磁盘中的位置 (扇区�?-> 柱面�? 起始扇区, 磁头�?
	; -----------------------------------------------------------------------
	; 设扇区号�?x
	;                           �?柱面�?= y >> 1
	;       x           �?�?y �?	; -------------- => �?     �?磁头�?= y & 1
	;  每磁道扇区数     �?	;                   �?�?z => 起始扇区�?= z + 1
	push	bp
	mov		bp,sp
	sub		esp,2					;辟出两个字节的堆栈区域保存要读的扇区�? byte [bp-2]

	mov		byte[bp-2], cl
	push	bx						;保存 bx
	mov		bl,[BPB_SecPerTrk]		;bl: 除数
	div		bl						;y �?al �? z �?ah �?	inc		ah						;z ++
	mov		cl,ah					;cl <- 起始扇区�?	mov		dh,al					;dh <- y
	shr		al,1					;y >> 1 (其实�?y/BPB_NumHeads, 这里BPB_NumHeads=2)
	mov		ch,al					;ch <- 柱面�?	and		dh,1					;dh & 1 = 磁头�?	pop		bx						;恢复 bx
	;至此, "柱面�? 起始扇区, 磁头�?全部得到
	mov		dl,[BS_DrvNum]			;驱动器号 (0 表示 A �?
.GoOnReading:
	mov		ah,2					;�?	mov		al,byte[bp-2]			;�?al 个扇�?	int		13h
	jc		.GoOnReading			;如果读取错误 CF 会被置为 1, 这时就不停地�? 直到正确为止

	add		esp,2
	pop		bp

	ret

;----------------------------------------------------------------------------
; 函数�? GetFATEntry
;----------------------------------------------------------------------------
; 作用:
;	找到序号�?ax �?Sector �?FAT 中的条目, 结果放在 ax �?;	需要注意的�? 中间需要读 FAT 的扇区到 es:bx �? 所以函数一开始保存了 es �?bx
GetFATEntry:
	push	es
	push	bx
	push	ax
	mov		ax,file_addr_segment		; `.
	sub		ax,0100h			;  | �?file_addr_segment 后面留出 4K 空间用于存放 FAT
	mov		es, ax				; /
	pop		ax
	mov		byte [bOdd],0
	mov		bx,3
	mul		bx					;dx:ax = ax * 3
	mov		bx,2
	div		bx					;dx:ax / 2  ==>  ax <- �? dx <- 余数
	cmp		dx,0
	jz		LABEL_EVEN
	mov		byte[bOdd],1
LABEL_EVEN:;偶数
	;现在 ax 中是 FATEntry �?FAT 中的偏移�?下面来计�?FATEntry 在哪个扇区中(FAT占用不止一个扇�?
	xor		dx,dx			
	mov		bx,[BPB_BytsPerSec]
	div		bx					;dx:ax / BPB_BytsPerSec
; ax <- �?(FATEntry 所在的扇区相对�?FAT 的扇区号)
; dx <- 余数 (FATEntry 在扇区内的偏�?�?	push	dx
	mov		bx,0 				;bx <- 0 于是, es:bx = (file_addr_segment - 100):00
	add		ax,SectorNoOfFAT1 ; 此句之后�?ax 就是 FATEntry 所在的扇区�?	mov		cl,2
	call	ReadSector 			;读取 FATEntry 所在的扇区, 一次读两个, 避免在边界发生错�? 因为一�?FATEntry 可能跨越两个扇区
	pop		dx
	add		bx,dx
	mov		ax,[es:bx]
	cmp		byte[bOdd], 1
	jnz		LABEL_EVEN_2
	shr		ax,4
LABEL_EVEN_2:
	and		ax,0FFFh
LABEL_GET_FAT_ENRY_OK:
	pop		bx
	pop		es
	ret

	times 	510-($-$$)	db	0	; 填充剩下的空间，使生成的二进制代码恰好为512字节
	dw 		0xaa55				; 结束标志
