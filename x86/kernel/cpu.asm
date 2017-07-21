;Copyright 2013-2014 by Explorer Developer.
;made by Hu wenjie(CN)<1@GhostBirdOS.org>
;Explorer part of CPU
;Explorer 0.01/arch/x86/kernel/cpu.asm
;version:Alpha
;8/30/2014 8:16 PM

;global varies
global	CPU_MAXID
global	CPU_EMAXID
global	CPU_OME

;global function
global	init_CPU

[section .text]
[bits 32]
init_CPU:
	xor		eax,eax
	cpuid
	;get max value of cpuid instruction
	mov		[CPU_MAXID],eax
	;get OME of CPU
	mov		[CPU_OME],ebx
	mov		[CPU_OME+4],edx
	mov		[CPU_OME+8],ecx
	
	mov		eax,0x80000000
	cpuid
	;get extended max value of cpuid instruction
	mov		[CPU_EMAXID],eax
	ret
	
[section .data]
CPU_MAXID	dd 0x00
CPU_EMAXID	dd 0x00
CPU_OME	 	dd 0x00,0x00,0x00
			db 0x00;end of string
