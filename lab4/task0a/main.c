#include "util.h"

#define SYS_WRITE 4
#define STDOUT 1

int main (int argc , char* argv[], char* envp[])
{
  system_call(SYS_WRITE,STDOUT,"hello world",11);
  return 0;
}
