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
#define EXIT 1
#define BUF_SIZE 8192
#define SYS_GETDENTS 141


struct linux_dirent {
  long           d_ino;
  long          d_off;
  unsigned short d_reclen;
  char           d_name[];
};

int main (int argc , char* argv[], char* envp[])
{
  int file, nread, readerStatus = 0, containsD, code1, code2, code3, i;
  char buf[BUF_SIZE], d_type;
  int bpos;
  struct linux_dirent *linux_dirent;
  file = system_call(OPEN,".", O_RDONLY);
  for (i = 0 ; i < argc ; i++)
    {
      if (!strncmp("-D", argv[i], 2)) /*if one of the arguments is -D*/
      {
        containsD = true;
      }
    }
  if (file<0)
  {
    system_call(EXIT, 0X55, 1, 1);
  }
  nread = system_call(SYS_GETDENTS, file, buf, BUF_SIZE);
  if (nread < 0){
      system_call(EXIT, 0X55, 1, 1);
    }
  while (readerStatus < nread)
  {
    if (containsD){
        printDebug(SYS_GETDENTS, nread);
    }

      linux_dirent = (struct linux_dirent *) (buf + readerStatus);
      readerStatus = readerStatus + linux_dirent->d_reclen;
      code1 = system_call(WRITE,STDOUT,linux_dirent->d_name,strlen(linux_dirent->d_name));
      system_call(WRITE,STDOUT,"\t",1);
      code2 = system_call(WRITE,STDOUT,itoa(linux_dirent->d_reclen),strlen(itoa(linux_dirent->d_reclen)));
      code3 = system_call(WRITE,STDOUT,"\n",1);
      if (containsD){
        printDebug(WRITE, code1);
        printDebug(WRITE, code2);
        printDebug(WRITE, code3);
      }
  }
  system_call(CLOSE, file);
  return 0;
}

void printDebug (int systemCall, int code){
  char* printS = itoa(systemCall);
  system_call(WRITE, STDERR,"\t the system call is: " , strlen("\t the system call is: "));
  system_call(WRITE, STDERR, printS, strlen(printS));

  printS = itoa(code);
  system_call(WRITE, STDERR,"\t the code is: " , strlen("\t the code is: "));
  system_call(WRITE, STDERR, printS, strlen(printS));
  system_call(WRITE, STDERR, "\n", strlen("\n"));
}