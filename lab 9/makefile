infector: infector.o
	ld -m elf_i386 -o infector infector.o
 
infector.o: infector.s
	nasm -g -f elf -Wall -o infector.o infector.s

.PHONY: clean
clean:
	rm -rf ./*.o infector
