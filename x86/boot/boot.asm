
	org  0x7c00
	
	stack_base				equ	07c00h	;
	file_addr_segment		equ	0x1000	;æ–‡ä»¶è¢«åŠ è½½åˆ°çš„ä½ç½?æ®µåœ°å€)
	file_addr_offset		equ	0x0		;æ–‡ä»¶è¢«åŠ è½½åˆ°çš„ä½ç½?åç§»åœ°å€)
	RootDirSectors			equ	14		;æ ¹ç›®å½•å ç”¨ç©ºé—?	root_sector				equ	19		;æ ¹ç›®å½•çš„ç¬¬ä¸€ä¸ªæ‰‡åŒºå·
	SectorNoOfFAT1			equ	1		;FAT1 çš„ç¬¬ä¸€ä¸ªæ‰‡åŒºå· = BPB_RsvdSecCnt
	DeltaSectorNo			equ	17
	
	;ä¸‹é¢æ˜?FAT12 ç£ç›˜çš„å¤´
	jmp short boot_start
	nop
	BS_OEMName		DB 'AN'	; OEM String, å¿…é¡» 8 ä¸ªå­—èŠ?	BPB_BytsPerSec	DW 512			; æ¯æ‰‡åŒºå­—èŠ‚æ•°
	BPB_SecPerClus	DB 1			; æ¯ç°‡å¤šå°‘æ‰‡åŒº
	BPB_RsvdSecCnt	DW 1			; Boot è®°å½•å ç”¨å¤šå°‘æ‰‡åŒº
	BPB_NumFATs		DB 2			; å…±æœ‰å¤šå°‘ FAT è¡?	BPB_RootEntCnt	DW 224			; æ ¹ç›®å½•æ–‡ä»¶æ•°æœ€å¤§å€?	BPB_TotSec16	DW 2880			; é€»è¾‘æ‰‡åŒºæ€»æ•°
	BPB_Media		DB 0xF0			; åª’ä½“æè¿°ç¬?	BPB_FATSz16		DW 9			; æ¯FATæ‰‡åŒºæ•?	BPB_SecPerTrk	DW 18			; æ¯ç£é“æ‰‡åŒºæ•°
	BPB_NumHeads	DW 2			; ç£å¤´æ•?é¢æ•°)
	BPB_HiddSec		DD 0			; éšè—æ‰‡åŒºæ•?	BPB_TotSec32	DD 0			; å¦‚æžœ wTotalSectorCount æ˜?0 ç”±è¿™ä¸ªå€¼è®°å½•æ‰‡åŒºæ•°
	BS_DrvNum		DB 0			; ä¸­æ–­ 13 çš„é©±åŠ¨å™¨å?	BS_Reserved1	DB 0			; æœªä½¿ç”?	BS_BootSig		DB 29h			; æ‰©å±•å¼•å¯¼æ ‡è®° (29h)
	BS_VolID		DD 0			; å·åºåˆ—å·
	BS_VolLab		DB 'GhostBirdOS'; å·æ ‡, å¿…é¡» 11 ä¸ªå­—èŠ?	BS_FileSysType	DB 'FAT12   '	; æ–‡ä»¶ç³»ç»Ÿç±»åž‹, å¿…é¡» 8ä¸ªå­—èŠ? 

boot_start:	
	mov		ax,cs
	mov		ds,ax
	mov		es,ax
	mov		ss,ax
	mov		sp,stack_base

	;æ¸…å±
	mov		ax,0600h
	mov		bx,0700h
	mov		cx,0
	mov		dx,0184fh
	int		10h
	;æ˜¾ç¤º"Booting"
	mov		dh,0
	call	DispStr
	;è½¯é©±å¤ä½
	xor		ah,ah
	xor		dl,dl
	int		13h
	
	;ä¸‹é¢åœ¨è½¯ç›˜çš„æ ¹ç›®å½•å¯»æ‰¾æ–‡ä»?	mov		word[read_sector],root_sector
begin_search:
	;åˆ¤æ–­æ ¹ç›®å½•æ˜¯å¦è¯»å®Œï¼Œè¯»å®Œè¡¨ç¤ºæ²¡æœ‰æ‰¾åˆ°æ–‡ä»¶
	cmp		word[root_sector_num],0
	jz		nofound
	dec		word[root_sector_num]
	mov		ax,file_addr_segment
	mov		es,ax										;es <- file_addr_segment
	mov		bx,file_addr_offset							;bx <- file_addr_offset	äºŽæ˜¯, es:bx = file_addr_segment:file_addr_offset
	mov		ax,[read_sector]								;ax <- Root Directory ä¸­çš„æŸ?Sector å?	mov		cl,1
	call	ReadSector

	mov		si,KERNELFileName							;ds:si -> "KERNEL  "
	mov		di,file_addr_offset							;es:di -> file_addr_segment:0100 = file_addr_segment*10h+100
	cld
	mov		dx,10h

;å¾ªçŽ¯æ¬¡æ•°æŽ§åˆ¶
LABEL_SEARCH_FOR_KERNELBIN:
	cmp		dx,0										;â”“å¾ªçŽ¯æ¬¡æ•°æŽ§åˆ?
	jz		next_sector			;â”£å¦‚æžœå·²ç»è¯»å®Œäº†ä¸€ä¸?Sector,
	dec		dx											;â”›å°±è·³åˆ°ä¸‹ä¸€ä¸?Sector
	mov		cx,11

;å¯¹æ¯”æ–‡ä»¶å?cmp_filenasm:
	cmp		cx,0
	jz		filename_founded
	dec		cx
	lodsb
	cmp		al,byte[es:di]
	jz		LABEL_GO_ON
	;åˆ°è¿™é‡Œä»£è¡¨æ–‡ä»¶ååŒ¹é…ä¸ä¸€è‡?	jmp		filename_different
; æˆ‘ä»¬è¦æ‰¾çš?KERNEL
LABEL_GO_ON:
	inc		di
	jmp		cmp_filenasm							;ç»§ç»­å¾ªçŽ¯

;æ–‡ä»¶åä¸ä¸€è‡?filename_different:
	and		di,0FFE0h
	add		di,20h
	mov		si,KERNELFileName
	jmp		LABEL_SEARCH_FOR_KERNELBIN

;ä»Žä¸‹ä¸ªrootæ‰‡åŒºå¼€å§‹æœç´?next_sector:
	add		word[read_sector],1
	jmp		begin_search

;æ²¡æœ‰æ‰¾åˆ°æ–‡ä»¶
nofound:
	mov		dh,2										;"No KERNEL."
	call	DispStr										;æ˜¾ç¤ºå­—ç¬¦ä¸?	jmp		$											;æ²¡æœ‰æ‰¾åˆ°KERNELæ­»å¾ªçŽ¯åœ¨è¿™é‡Œ

;æ‰¾åˆ°æ–‡ä»¶
filename_founded:									;æ‰¾åˆ° KERNEL åŽä¾¿æ¥åˆ°è¿™é‡Œç»§ç»­
	mov		ax,RootDirSectors
	and		di,0FFE0h									;di -> å½“å‰æ¡ç›®çš„å¼€å§?	add		di,01Ah										;di -> é¦?Sector
	mov		cx,word[es:di]
	push	cx											;ä¿å­˜æ­?Sector åœ?FAT ä¸­çš„åºå·
	add		cx,ax
	add		cx,DeltaSectorNo							;cl <- KERNELçš„èµ·å§‹æ‰‡åŒºå·(0-based)
	mov		ax,file_addr_segment
	mov		es,ax										;es <- file_addr_segment
	mov		bx,file_addr_offset							;bx <- file_addr_offset
	mov		ax,cx										;ax <- Sector å?
;åŠ è½½æ–‡ä»¶
loading_file:
	;æ¯è¯»ä¸€ä¸ªæ‰‡åŒºå°±åœ?Booting"åŽé¢æ‰“ä¸€ä¸ªç‚¹
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
	pop		ax											;å–å‡ºæ­?Sector åœ?FAT ä¸­çš„åºå·
	call	GetFATEntry
	cmp		ax,0FFFh
	jz		load_finished
	push	ax											;ä¿å­˜ Sector åœ?FAT ä¸­çš„åºå·
	mov		dx,RootDirSectors
	add		ax,dx
	add		ax,DeltaSectorNo
	add		bx,[BPB_BytsPerSec]
	jmp		loading_file
load_finished:
	;æ˜¾ç¤º"Ready."
	mov		dh,1
	call	DispStr

	;è·³è½¬åˆ°å·²ç»åŠ è½½çš„æ–‡ä»¶ä¸?	jmp		file_addr_segment:file_addr_offset

;å˜é‡
	;æ ¹ç›®å½•æ‰‡åŒºæ€»æ•°
	root_sector_num		dw	RootDirSectors	;Root Directory å ç”¨çš„æ‰‡åŒºæ•°, åœ¨å¾ªçŽ¯ä¸­ä¼šé€’å‡è‡³é›¶.
	read_sector			dw	0				;è¦è¯»å–çš„æ‰‡åŒºå?	bOdd				db	0				;å¥‡æ•°è¿˜æ˜¯å¶æ•°

;============================================================================
;å­—ç¬¦ä¸?;----------------------------------------------------------------------------
KERNELFileName		db	"KERNEL     ", 0	; KERNEL ä¹‹æ–‡ä»¶å
; ä¸ºç®€åŒ–ä»£ç ? ä¸‹é¢æ¯ä¸ªå­—ç¬¦ä¸²çš„é•¿åº¦å‡ä¸º MessageLength
MessageLength		equ	9
BootMessage:		db	"Booting  "; 9å­—èŠ‚, ä¸å¤Ÿåˆ™ç”¨ç©ºæ ¼è¡¥é½. åºå· 0
Message1		db	"Ready.   "; 9å­—èŠ‚, ä¸å¤Ÿåˆ™ç”¨ç©ºæ ¼è¡¥é½. åºå· 1
Message2		db	"No KERNEL"; 9å­—èŠ‚, ä¸å¤Ÿåˆ™ç”¨ç©ºæ ¼è¡¥é½. åºå· 2
;============================================================================


;----------------------------------------------------------------------------
; å‡½æ•°å? DispStr
;----------------------------------------------------------------------------
; ä½œç”¨:
;	æ˜¾ç¤ºä¸€ä¸ªå­—ç¬¦ä¸², å‡½æ•°å¼€å§‹æ—¶ dh ä¸­åº”è¯¥æ˜¯å­—ç¬¦ä¸²åºå?0-based)
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
; å‡½æ•°å? ReadSector
;----------------------------------------------------------------------------
; ä½œç”¨:
;	ä»Žç¬¬ ax ä¸?Sector å¼€å§? å°?cl ä¸?Sector è¯»å…¥ es:bx ä¸?ReadSector:
	; -----------------------------------------------------------------------
	; æ€Žæ ·ç”±æ‰‡åŒºå·æ±‚æ‰‡åŒºåœ¨ç£ç›˜ä¸­çš„ä½ç½® (æ‰‡åŒºå?-> æŸ±é¢å? èµ·å§‹æ‰‡åŒº, ç£å¤´å?
	; -----------------------------------------------------------------------
	; è®¾æ‰‡åŒºå·ä¸?x
	;                           â”?æŸ±é¢å?= y >> 1
	;       x           â”?å•?y â”?	; -------------- => â”?     â”?ç£å¤´å?= y & 1
	;  æ¯ç£é“æ‰‡åŒºæ•°     â”?	;                   â”?ä½?z => èµ·å§‹æ‰‡åŒºå?= z + 1
	push	bp
	mov		bp,sp
	sub		esp,2					;è¾Ÿå‡ºä¸¤ä¸ªå­—èŠ‚çš„å †æ ˆåŒºåŸŸä¿å­˜è¦è¯»çš„æ‰‡åŒºæ•? byte [bp-2]

	mov		byte[bp-2], cl
	push	bx						;ä¿å­˜ bx
	mov		bl,[BPB_SecPerTrk]		;bl: é™¤æ•°
	div		bl						;y åœ?al ä¸? z åœ?ah ä¸?	inc		ah						;z ++
	mov		cl,ah					;cl <- èµ·å§‹æ‰‡åŒºå?	mov		dh,al					;dh <- y
	shr		al,1					;y >> 1 (å…¶å®žæ˜?y/BPB_NumHeads, è¿™é‡ŒBPB_NumHeads=2)
	mov		ch,al					;ch <- æŸ±é¢å?	and		dh,1					;dh & 1 = ç£å¤´å?	pop		bx						;æ¢å¤ bx
	;è‡³æ­¤, "æŸ±é¢å? èµ·å§‹æ‰‡åŒº, ç£å¤´å?å…¨éƒ¨å¾—åˆ°
	mov		dl,[BS_DrvNum]			;é©±åŠ¨å™¨å· (0 è¡¨ç¤º A ç›?
.GoOnReading:
	mov		ah,2					;è¯?	mov		al,byte[bp-2]			;è¯?al ä¸ªæ‰‡åŒ?	int		13h
	jc		.GoOnReading			;å¦‚æžœè¯»å–é”™è¯¯ CF ä¼šè¢«ç½®ä¸º 1, è¿™æ—¶å°±ä¸åœåœ°è¯? ç›´åˆ°æ­£ç¡®ä¸ºæ­¢

	add		esp,2
	pop		bp

	ret

;----------------------------------------------------------------------------
; å‡½æ•°å? GetFATEntry
;----------------------------------------------------------------------------
; ä½œç”¨:
;	æ‰¾åˆ°åºå·ä¸?ax çš?Sector åœ?FAT ä¸­çš„æ¡ç›®, ç»“æžœæ”¾åœ¨ ax ä¸?;	éœ€è¦æ³¨æ„çš„æ˜? ä¸­é—´éœ€è¦è¯» FAT çš„æ‰‡åŒºåˆ° es:bx å¤? æ‰€ä»¥å‡½æ•°ä¸€å¼€å§‹ä¿å­˜äº† es å’?bx
GetFATEntry:
	push	es
	push	bx
	push	ax
	mov		ax,file_addr_segment		; `.
	sub		ax,0100h			;  | åœ?file_addr_segment åŽé¢ç•™å‡º 4K ç©ºé—´ç”¨äºŽå­˜æ”¾ FAT
	mov		es, ax				; /
	pop		ax
	mov		byte [bOdd],0
	mov		bx,3
	mul		bx					;dx:ax = ax * 3
	mov		bx,2
	div		bx					;dx:ax / 2  ==>  ax <- å•? dx <- ä½™æ•°
	cmp		dx,0
	jz		LABEL_EVEN
	mov		byte[bOdd],1
LABEL_EVEN:;å¶æ•°
	;çŽ°åœ¨ ax ä¸­æ˜¯ FATEntry åœ?FAT ä¸­çš„åç§»é‡?ä¸‹é¢æ¥è®¡ç®?FATEntry åœ¨å“ªä¸ªæ‰‡åŒºä¸­(FATå ç”¨ä¸æ­¢ä¸€ä¸ªæ‰‡åŒ?
	xor		dx,dx			
	mov		bx,[BPB_BytsPerSec]
	div		bx					;dx:ax / BPB_BytsPerSec
; ax <- å•?(FATEntry æ‰€åœ¨çš„æ‰‡åŒºç›¸å¯¹äº?FAT çš„æ‰‡åŒºå·)
; dx <- ä½™æ•° (FATEntry åœ¨æ‰‡åŒºå†…çš„åç§?ã€?	push	dx
	mov		bx,0 				;bx <- 0 äºŽæ˜¯, es:bx = (file_addr_segment - 100):00
	add		ax,SectorNoOfFAT1 ; æ­¤å¥ä¹‹åŽçš?ax å°±æ˜¯ FATEntry æ‰€åœ¨çš„æ‰‡åŒºå?	mov		cl,2
	call	ReadSector 			;è¯»å– FATEntry æ‰€åœ¨çš„æ‰‡åŒº, ä¸€æ¬¡è¯»ä¸¤ä¸ª, é¿å…åœ¨è¾¹ç•Œå‘ç”Ÿé”™è¯? å› ä¸ºä¸€ä¸?FATEntry å¯èƒ½è·¨è¶Šä¸¤ä¸ªæ‰‡åŒº
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

	times 	510-($-$$)	db	0	; å¡«å……å‰©ä¸‹çš„ç©ºé—´ï¼Œä½¿ç”Ÿæˆçš„äºŒè¿›åˆ¶ä»£ç æ°å¥½ä¸º512å­—èŠ‚
	dw 		0xaa55				; ç»“æŸæ ‡å¿—
