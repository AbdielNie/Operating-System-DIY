.
:make
	@pause
	@nasm boot.asm -o boot.bin
	@goto make
