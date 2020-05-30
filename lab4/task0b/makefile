all:task0
task0:
	nasm  -f elf start.s -o start.o
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector main.c  -o main.o
	ld -m elf_i386 start.o main.o -o task0

.PHONY: clean
clean:
	rm -rf ./*.o task0