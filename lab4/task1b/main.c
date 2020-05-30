#include "util.h"

#define WRITE 4
#define STDOUT 1
#define true 1
#define false 0
#define STDIN 0
#define STDOUT 1
#define STDERR 2
#define SIZE_BUFFER 1
#define READ 3
#define OPEN 5
#define CLOSE 6
#define O_RDONLY 0
#define O_WRONLY 1
#define EXIT 0
#define O_CREATE 64

int main(int argc, char *argv[], char *envp[])
{
  int i;
  int systemCall = 0, retFromCall = 0, code = 0;
  int containsD = false;
  int containsI = false;
  int containsO = false;
  char readBuffer[SIZE_BUFFER];
  char *fileInput, *fileOutput;
  int oldVal = 0, newVal = 0, input = STDIN, output = STDOUT;

  for (i = 0; i < argc; i++)
  {
    if (!strncmp("-D", argv[i], 2)) /*if one of the arguments is -D*/
    {
      containsD = true;
    }
    else if (!strncmp("-i", argv[i], 2)) /*if one of the arguments is -i*/
    {
      containsI = true;
      fileInput = argv[i] + 2;
    }
    else if (!strncmp("-o", argv[i], 2)) /*if one of the arguments is -o*/
    {
      containsO = true;
      fileOutput = argv[i] + 2;
    }
  }

  if (containsI)
  {
    input = system_call(OPEN, fileInput, O_RDONLY);
    if (containsD)
    {
      system_call(WRITE, STDERR, fileInput, strlen(fileInput));
      system_call(WRITE, STDERR, "\n", strlen("\n"));
      printDebug(OPEN, input);
    }
    if (input < 0)
    {
      system_call(WRITE, STDOUT, "couldn't open file\n", strlen("couldn't open file\n"));
      system_call(1,0x55,1,1); /*exit* system call code, status, two doesnt matter*/
    }
  }

  if (containsO)
  {
    output = system_call(OPEN, fileOutput, O_WRONLY | O_CREATE,0777);
    if (containsD)
    {
      system_call(WRITE, STDERR, fileOutput, strlen(fileOutput));
      system_call(WRITE, STDERR, "\n", strlen("\n"));
      printDebug(OPEN, output);
    }
    if (output < 0)
    {
      system_call(WRITE, STDOUT, "couldn't open file\n", strlen("couldn't open file\n"));
      system_call(1,0x55,1,1); /*exit* system call code, status, two doesnt matter*/
    }
  }

  code = system_call(READ, input, readBuffer, 1);
  if (containsD)
  {
    if (fileOutput)
    {
      system_call(WRITE, STDERR, fileOutput, strlen(fileOutput));
    }
    else
    {
      system_call(WRITE, STDERR, "stdout", strlen("stdout"));
    }
    system_call(WRITE, STDERR, "\n", strlen("\n"));
    printDebug(READ, code);
  }

  while (code != 0)
  {
    oldVal = readBuffer[0];
    newVal = oldVal;
    if ('a' <= oldVal & 'z' >= oldVal)
    {
      newVal = 'A' + oldVal - 'a';
    }
    readBuffer[0] = newVal;
    code = system_call(WRITE, output, readBuffer, 1);
    if (containsD)
    {
      if (fileOutput)
      {
        system_call(WRITE, STDERR, fileOutput, strlen(fileOutput));
      }
      else
      {
        system_call(WRITE, STDERR, "stdout", strlen("stdout"));
      }
      system_call(WRITE, STDERR, "\n", strlen("\n"));
      printDebug(WRITE, code);
    }

    code = system_call(READ, input, readBuffer, 1);
    if (containsD)
    {
      if (fileInput)
      {
        system_call(WRITE, STDERR, fileInput, strlen(fileInput));
      }
      else
      {
        system_call(WRITE, STDERR, "stdin", strlen("stdin"));
      }
      system_call(WRITE, STDERR, "\n", strlen("\n"));
      printDebug(READ, code);
    }
  }

  system_call(CLOSE, input);
  system_call(CLOSE, output);

  return 0;
}

void printDebug(int systemCall, int code)
{
  char *printS = itoa(systemCall);
  system_call(WRITE, STDERR, "\t the system call is: ", strlen("\t the system call is: "));
  system_call(WRITE, STDERR, printS, strlen(printS));

  printS = itoa(code);
  system_call(WRITE, STDERR, "\t the code is: ", strlen("\t the code is: "));
  system_call(WRITE, STDERR, printS, strlen(printS));
  system_call(WRITE, STDERR, "\n", strlen("\n"));
}
