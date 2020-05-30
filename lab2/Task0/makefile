#format is target-name: target dependencies
#{-tab-}actions
# All Targets
all: count-words

# Tool invocations
# Executable "hello" depends on the files hello.o and encoder.o.
count-words: count-words.o
	gcc -g  -m32 -Wall -o count-words count-words.o
 
count-words.o: count-words.c
	gcc -m32 -g -Wall -c -o count-words.o count-words.c


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o count-words
