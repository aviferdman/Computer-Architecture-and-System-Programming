#format is target-name: target dependencies
#{-tab-}actions
# All Targets
all: lab3_bubblesort

# Tool invocations

lab3_bubblesort: lab3_bubblesort.o
	gcc -g  -m32 -Wall -o lab3_bubblesort lab3_bubblesort.o
 
lab3_bubblesort.o:lab3_bubblesort.c
	gcc -m32 -g -Wall -c -o lab3_bubblesort.o lab3_bubblesort.c


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o lab3_bubblesort
