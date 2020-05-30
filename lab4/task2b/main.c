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
# define DT_UNKNOWN 0
# define DT_FIFO 1
# define DT_CHR 2     
# define DT_DIR 4    
# define DT_BLK 6
# define DT_REG 8
# define DT_LNK 10                
# define DT_SOCK 12
# define DT_WHT 14


struct linux_dirent {
  long           d_ino;
  long          d_off;
  unsigned short d_reclen;
  char           d_name[];
};

int main (int argc , char* argv[], char* envp[])
{
  int file, bytesRead, i, containsP = false, readerStatus=0, code1, code2,code3, containsD, d_type;
  char buf [BUF_SIZE], *pref;
  struct linux_dirent *linux_dirent;
  file = system_call(OPEN,".", O_RDONLY);
  if (file<0)
  {
    system_call(EXIT,0X55,1,1); 
  }
  for (i = 0 ; i < argc ; i++)
  {
    if (!strncmp("-p", argv[i], 2)) /*if one of the arguments is -D*/
    {
      containsP = true;
      pref = argv[i] + 2;
    }
    if (!strncmp("-D", argv[i], 2)) /*if one of the arguments is -D*/
    {
      containsD = true;
    }
  }
  bytesRead = system_call(SYS_GETDENTS, file, buf, BUF_SIZE);
  if (bytesRead < 0){
      system_call(EXIT,0X55,1,1);
    }
  while (readerStatus < bytesRead)
  {
      linux_dirent = (struct linux_dirent *) (buf + readerStatus);
      d_type = *(buf + readerStatus + linux_dirent->d_reclen - 1);
      if (!containsP){
        printType(d_type, containsD);
        code1 = system_call(WRITE,STDOUT,linux_dirent->d_name,strlen(linux_dirent->d_name));
        system_call(WRITE,STDOUT,"\t",1);
        code2 = system_call(WRITE,STDOUT,itoa(linux_dirent->d_reclen),strlen(itoa(linux_dirent->d_reclen)));
        system_call(WRITE,STDOUT,"\n",1);
        if (containsD){
          printDebug(WRITE, code1);
          printDebug(WRITE, code2);
          printDebug(WRITE, code3);
        }
      }

      else if (containsP && strncmp(linux_dirent->d_name, pref, strlen(pref)) == 0)
      {
        printType(d_type, containsD);
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
      readerStatus = readerStatus + linux_dirent->d_reclen;
  }
  system_call(CLOSE, file);
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

void printType(int d_type, int containsD){
  int code1;
  switch (d_type)
  {
    case DT_REG:
      code1 = system_call(WRITE,STDOUT,"regular\t",strlen("regular\t"));
      break;
    case DT_DIR:
      code1 = system_call(WRITE,STDOUT,"directory\t",strlen("directory\t"));
      break;
    case DT_FIFO:
      code1 = system_call(WRITE,STDOUT,"FIFO\t",strlen("FIFO\t"));
      break;
    case DT_SOCK:
      code1 = system_call(WRITE,STDOUT,"socket\t",strlen("socket\t"));
      break;
    case DT_LNK:
      code1 = system_call(WRITE,STDOUT,"symlink\t",strlen("symlink\t"));
      break;
    case DT_BLK:
      code1 = system_call(WRITE,STDOUT,"block dev\t",strlen("block dev\t"));
      break;
    case DT_CHR:
      code1 = system_call(WRITE,STDOUT,"char dev\t",strlen("char dev\t"));
      break;
    default:
      break;
  }
  if (containsD)
  {
    printDebug(WRITE, code1);
  }  
}