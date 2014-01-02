#myos.bin : myos.asm Makefile
#	nasm myos.asm -o myos.bin

default :
	make img

bootloader.bin : bootloader.asm Makefile
	nasm bootloader.asm -o bootloader.bin

init_gdt.bin : init_gdt.asm Makefile
	nasm init_gdt.asm -o init_gdt.bin

asm_func.bin : asm_func.asm Makefile
	nasm -f elf asm_func.asm -o asm_func.bin

myos_asm.bin : myos_asm.asm Makefile
	nasm -f elf myos_asm.asm -o myos_asm.bin

myos_c.bin : myos_c.c Makefile
	i586-elf-gcc -c myos_c.c -o myos_c.bin -m32

myos.img : myos_c.bin myos_asm.bin asm_func.bin Makefile
	i586-elf-ld -s -Ttext=0x0 -o myos.img \
		myos_c.bin myos_asm.bin asm_func.bin

img : 
	make init_gdt.bin bootloader.bin asm_func.bin \
		myos_c.bin myos_asm.bin myos.img 
	dd if=/dev/zero of=./a.img bs=512 count=2880
	dd if=bootloader.bin of=a.img conv=notrunc
	dd if=init_gdt.bin of=a.img bs=512 seek=1
	dd if=myos.img of=a.img bs=512 seek=2

run :
	bochs -f ../.bochsrc

clean :
	rm *.bin *.img

