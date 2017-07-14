extern	int_keyboard_display
global	int_keyboard

[section .text]
[bits 32]
	
	port_keydat				equ	0x0060
	port_keysta				equ	0x0064
	port_keycmd				equ	0x0064
	keysta_send_notready	equ	0x02
	keycmd_write_mode		equ	0x60
	kbc_mode				equ	0x47
	extern	int_timer
	
;�豸�ж�����

int_keyboard:
	;����������
	pushad
	;�����ں�̬�����ݶ�
	mov		dx,ss
	mov		ds,dx
	mov		es,dx
	;�жϴ�����
	xor		eax,eax
	in		al,keycmd_write_mode
	push	eax
	call	int_keyboard_display
	add		esp,4
	;EOI
	mov		al,20h
	out		20h,al
	out		0xa0,al
	popad
	iretd
	