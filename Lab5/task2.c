#include "LineParser.h"
#include <linux/limits.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sys/wait.h>
#define MAX_LINE 2048
#define TERMINATED -1
#define RUNNING 1
#define SUSPENDED 0

int debug=0;
char input[MAX_LINE];
__pid_t pid;

typedef struct process{
    cmdLine* cmd;            /* the parsed command line*/
    pid_t pid; 		         /* the process id that is running the command*/
    int status;              /* status of the process: RUNNING/SUSPENDED/TERMINATED */
    struct process *next;	 /* next process in chain */
} process;

process * head = NULL;

void updateProcessStatus(process* process_list, int pid, int status);

void addProcess(process** process_list, cmdLine* cmd, pid_t pid){
    process * toAdd = (process*)calloc(1,sizeof(process));
    toAdd->cmd=cmd;
    toAdd->pid=pid;
    toAdd->status = RUNNING;
    toAdd->next=NULL;
    if(*process_list==NULL){
        *process_list=toAdd;
        return;
    }
    process * iter = *process_list;
    while (iter->next!=NULL)
        iter=iter->next;
    iter->next=toAdd;
}


void printProc(int idx,process * proc){
    printf("Index in process list: %d\n",idx);
    printf("pid: %d\n",proc->pid);
    printf("command: %s\n",proc->cmd->arguments[0]);
    printf("arguments: ");
    for(int i=1;i<proc->cmd->argCount;i++)printf("%s\t",proc->cmd->arguments[i]);
    printf("\n");
    printf("status: ");
    proc->status == TERMINATED ? printf("TERMINATED\n") :
    proc->status == RUNNING ? printf("RUNNING\n") : printf("SUSPENDED\n");
}

void finishCommand(cmdLine * pCmdLine){
    if(debug)
        printf("executing: %s pid is: %d \n",input,pid);
    addProcess(&head,pCmdLine,pid);
}


void cd(char * target){
    int err=0;
    if(!target)perror("couldn't execute cd command without target directory!");
    err = chdir(target);
    if(err==-1) perror("couldn't find the directory specified!");
}

void execute(cmdLine *pCmdLine){
    int stat;
    pid = fork();
    if(pCmdLine->blocking == 1)
        waitpid(pid,&stat,0);
    if(pid ==0){
        execvp(pCmdLine-> arguments[0],pCmdLine->arguments);
        perror("execution went wrong!");
        exit(-1);
    }
   
}

void freeProcessList(process* process_list){
    if(process_list!=NULL){
        if(process_list->next!=NULL){
            freeProcessList(process_list->next);
        }
        if(process_list->cmd)
            freeCmdLines(process_list->cmd);
        free(process_list);
    }
}

void updateProcessList(process **process_list){
    pid_t result=0;
    int status=0;
    if(!process_list)return;
    process * temp = *process_list;
    if(!temp)return;
    while (temp!=NULL)
    {
        result = waitpid(temp->pid,&status,WNOHANG | WUNTRACED | WCONTINUED);
        printf("pid in update:%d and status:%d\n",temp->pid,status);
        if(result==-1 || WIFSIGNALED(status)){
            updateProcessStatus(*process_list,temp->pid,TERMINATED);
        }else if(WIFCONTINUED(status)){          
            updateProcessStatus(*process_list,temp->pid,RUNNING);
        } else if(WIFSTOPPED(status)){
            updateProcessStatus(*process_list,temp->pid,SUSPENDED);
        }
        temp = temp->next;
    }
}

void deleteProc(process**process_list,process * toDelete){
    
    //check if toDelete is head
    process * first = *process_list;
    if(first==toDelete){
        *process_list=(*process_list)->next;
        freeCmdLines(first->cmd);
        free(first);
        return;
    }
    while (first->next!=toDelete)
        first=first->next;
    //now we have head -> ... first -> toDelete -> ...(possibly null!)
    first->next=toDelete->next; 
    toDelete->next=NULL; //now toDelete is fully detached.
    //safe deletion
    freeCmdLines(toDelete->cmd); //free its commands
    free(toDelete); //free its process
}

void printProcessList(process** process_list){
    updateProcessList(process_list);
    if(!process_list)return;
    process * next = *process_list;
    process * prev = *process_list;
    int i=0;
    while (next != NULL)
    {
        printProc(i,next);
        if(next->status == TERMINATED){
            prev=next;
            next=next->next;
            deleteProc(process_list,prev);
            continue;
        }
        next=next->next;
        i++;
    }
    
}
void updateProcessStatus(process* process_list, int pid, int status){
    if(!process_list)return;
    if(process_list->pid == pid){process_list->status=status;return;}
    updateProcessStatus(process_list->next,pid,status);
}

int main(int argc, char * argv[]){
    int retFromKill=0;
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
            freeCmdLines(command);
            continue;
        }
        if(strcmp(command->arguments[0],"quit")==0){
            freeCmdLines(command);
            break;
        }
        if(strcmp(command->arguments[0],"procs")==0){
            printProcessList(&head);
            freeCmdLines(command);
            continue;
        }
        if(strcmp(command->arguments[0],"suspend")==0){
            retFromKill= kill(atoi(command->arguments[1]),SIGTSTP);
            freeCmdLines(command);
            if(retFromKill==-1)perror("suspend failed!");
            continue;
        }
        if(strcmp(command->arguments[0],"kill")==0){
            retFromKill=kill(atoi(command->arguments[1]),SIGINT);
            freeCmdLines(command);
            if(retFromKill==-1)perror("kill failed!");
            continue;
        }
        if(strcmp(command->arguments[0],"wake")==0){
            retFromKill=kill(atoi(command->arguments[1]),SIGCONT);
            freeCmdLines(command);
            if(retFromKill==-1)perror("wake failed!");
            continue;
        }
        execute(command);
        finishCommand(command);
    }
    freeProcessList(head);
    return 0;
    
}