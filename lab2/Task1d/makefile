#format is target-name: target dependencies
#{-tab-}actions
# All Targets
all: addresses[1]

# Tool invocations
# Executable "hello" depends on the files hello.o and encoder.o.
addresses[1]: addresses[1].o
	gcc -g  -m32 -Wall -o addresses[1] addresses[1].o
 
addresses[1].o:addresses[1].c
	gcc -m32 -g -Wall -c -o addresses[1].o addresses[1].c


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o addresses[1]
