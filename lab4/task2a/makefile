#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: main
main:
# Tool invocations
# Executable "hello" depends on the files hello.o and main.o.

	nasm -f	elf	start.s -o start.o
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector util.c -o util.o
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector main.c -o main.o
	ld -m elf_i386 start.o main.o util.o -o main

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o main