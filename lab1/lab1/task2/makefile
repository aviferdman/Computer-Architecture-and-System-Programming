#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: encoder

# Tool invocations
# Executable "hello" depends on the files hello.o and encoder.o.
encoder: encoder.o
	gcc -g -m32 -Wall -o encoder encoder.o
 
encoder.o: encoder.c
	gcc -m32 -g -Wall -c -o encoder.o encoder.c


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o encoder
