#format is target-name: target dependencies
#{-tab-}actions
# All Targets
all: task2

# Tool invocations
# Executable "hello" depends on the files hello.o and encoder.o.
task2: task2.o
	gcc -g  -m32 -Wall -o task2 task2.o
 
task2.o:task2.c
	gcc -m32 -g -Wall -c -o task2.o task2.c


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o task2
