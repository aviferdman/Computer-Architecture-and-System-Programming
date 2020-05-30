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

typedef struct Link {
    char* name;
    char* value;
    struct Link* next;
}Link;
Link* linked_list = NULL;
void addLink(Link** linked_list, char* name, char* value){

    Link * toAdd = (Link*)calloc(1,sizeof(Link));
    toAdd->name=name;
    toAdd->value=value;
    toAdd->next=NULL;
    if(*linked_list==NULL){
        *linked_list=toAdd;
        return;
    }
    Link * iter = *linked_list;
    while (iter) {
        if(strcmp(iter->name,name)==0){
            free(toAdd);
            iter->value = value;
            return;
        }
        iter = iter->next;
    }
    iter->next=toAdd;
}

void printLinkedList(Link * linked_list){
    int i=0;
    while (linked_list) {
        printf("%d. name is: %s\t",i, linked_list->name);
        printf("value is: %s\n",linked_list->value);
        i=i+1;
        linked_list = linked_list->next;
    }
}

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

char * getValue(char * name){
    Link * temp = linked_list;
    while (temp)
    {
        if(strcmp(temp->name,name)==0)
            return temp->value;
    }
    return NULL;
    
}

void activateVars(cmdLine * line){
    char * value;
    char * home;
    for(int i=0;i<line->argCount;i++){
        if(strncmp(line->arguments[i],"$",1)==0){
            // ls $i for example.
            value = getValue(&line->arguments[i][1]);
            if(!value){
                printf("No such variable!\n");
                return;
            }
            replaceCmdArg(line,i,value);
        }
        if(strcmp(line->arguments[i],"~")==0){
            home = getenv("HOME");
            if(!home){
                perror("couldn't find home env var");
                return;
            }
            replaceCmdArg(line,i,home);
        }
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
        activateVars(command);
        if(strcmp(command->arguments[0],"cd")==0){
            cd(command->arguments[1]);
            cleanCommand(command);
            continue;
        }
        if(strcmp(command->arguments[0],"set")==0){
            if(command->argCount<3){
                printf("wrong number of args in set command!\n");
                cleanCommand(command);
                continue;
            }
            char value[4096];
            strcpy(value,command->arguments[2]);
            for(int i=3;i<command->argCount;i++){
                strcat(value," ");
                strcat(value,command->arguments[i]);
            }
            addLink(&linked_list, command->arguments[1],value);
            //cleanCommand(command);
            continue;
        }
        if (strcmp(command->arguments[0],"vars")==0){  //i added this just to see the linked list is O.K
            printLinkedList(linked_list);
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