#include "util.h"
#define true 1
#define false 0
#define SIZE_BUFFER 1
#define READ 3
#define WRITE 4
#define STDIN 0
#define STDOUT 1
#define STDERR 2




int main (int argc, char * argv[]){

    int i, code, input = STDIN, output= STDOUT, oldVal = 0, newVal = 0, containsD = false;
    char readBuffer[SIZE_BUFFER];

    for (i = 0; i < argc; i++)
    {
        if (!strncmp ("-D", argv[i], 2)) /*if one of the arguments is -D */
        {
            containsD = true;
        }
    }
    
    
    code = system_call(READ, input, readBuffer, 1);
    if (containsD)
    {
        printDebug(WRITE, code);
    }

    while (code!=0)
    {
        oldVal = readBuffer[0];
        newVal = oldVal;
        if ('a'<=oldVal & 'z' >= oldVal)
        {
            newVal = 'A' + oldVal - 'a';
        }
        readBuffer[0] = newVal;
        code = system_call(WRITE, output, readBuffer, 1);
        if (containsD)
        {
            printDebug(WRITE, code);
        }
        code = system_call(READ, input, readBuffer, 1);
        if (containsD)
        {
            printDebug(READ, code);
        }
    }
    return 0;
}

void printDebug (int systemCall, int code){
    char* printS = itoa(systemCall);
    system_call(WRITE, STDERR, "\t the system call is: " , strlen("\t the system call is: "));
    system_call(WRITE, STDERR, printS, strlen(printS));
    printS = itoa(code);
    system_call(WRITE, STDERR, "\t the code is: ", strlen("\t the code is: "));
    system_call(WRITE, STDERR, printS, strlen(printS));
    system_call(WRITE, STDERR, "\n", strlen("\n"));
}