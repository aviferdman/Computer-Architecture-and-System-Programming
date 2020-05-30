#include "LineParser.h"
#include <linux/limits.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#define MAX_LINE 2048
#define STDIN 0
#define STDOUT 1

int debug=0;
char input[MAX_LINE];
__pid_t pid;


void cleanCommand(cmdLine * pCmdLine){
    if(debug)
        printf("executing: %s pid is: %d \n",input,pid);
    freeCmdLines(pCmdLine);
}


void cd(char * target){
    int err=0;
    if(!target)perror("couldn't execute cd command without target directory!");
    err = chdir(target);
    if(err==-1) perror("couldn't find the directory specified!");
}

void execute(cmdLine *pCmdLine){
    pid = fork();
    if(pCmdLine->blocking == 1) {
        waitpid(pid, NULL, 0);  //wait for child to finish
    }
    if(pid == 0){
        if(pCmdLine->outputRedirect){  // '>'
            fclose(stdout);
            if(!fopen(pCmdLine->outputRedirect,"a+"))
            {
                perror("couldn't redirect output!");
                exit(0);
            }
        }
        if(pCmdLine->inputRedirect){ // '<'
            fclose(stdin);
            if(!fopen(pCmdLine->inputRedirect,"r")){
                perror("couldn't redirect input!");
                exit(0);
            }
        }

        execvp(pCmdLine-> arguments[0],pCmdLine->arguments);    //exec child
        perror("execution went wrong!");
        exit(-1);
    }
}

int main(int argc, char * argv[]){
    char path[PATH_MAX];
    cmdLine * command;
    for(int i=1;i<argc;i++){
        if(strncmp("-d",argv[i],2)==0)
            debug=1;
    }
    while (1)
    {
        printf("%s> ",getcwd(path,PATH_MAX));
        fgets(input,MAX_LINE,stdin);
        command = parseCmdLines(input);
        if(strcmp(command->arguments[0],"cd")==0){
            cd(command->arguments[1]);
            cleanCommand(command);
            continue;
        }
        if(strcmp(command->arguments[0],"quit")==0){
            cleanCommand(command);
            break;
        }
        
        execute(command);
        cleanCommand(command);
    }
    return 0;
}