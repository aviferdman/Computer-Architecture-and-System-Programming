

#define SYS_WRITE 4
#define STDOUT 1

int main (int argc , char* argv[], char* envp[])
{
  unsigned int fd;
  char nulls[5] = "mira ";
    fd = system_call(5,"greeting", "r+" , 0644);
    system_call(19, fd, 657, 0);
    system_call(SYS_WRITE,fd, nulls, 5);
    system_call(6, fd);
}
