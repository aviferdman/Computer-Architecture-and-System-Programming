all: task1 task4

task1: task1.o
	gcc -g -m32 task1.o -o hexeditplus

task1.o: task1.c
	gcc -g -m32 -c -o task1.o task1.c

task4: task4.o
	gcc -g -m32 -fno-pie task4.o -o digits

task4.o: task4.c
	gcc -g -m32 -fno-pie -c -o task4.o task4.c

.PHONY: clean
clean:
	rm -r task1.o hexeditplus task4.o digits
