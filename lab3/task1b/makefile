#format is target-name: target dependencies
#{-tab-}actions
# All Targets
all: virusDetector

# Tool invocations

virusDetector: virusDetector.o
	gcc -g  -m32 -Wall -o virusDetector virusDetector.o
 
virusDetector.o:virusDetector.c
	gcc -m32 -g -Wall -c -o virusDetector.o virusDetector.c


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o virusDetector
