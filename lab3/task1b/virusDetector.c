#include <stdio.h>
#include <stdlib.h>

typedef struct virus
{
    unsigned short SigSize;
    char virusName [16];
    char* sig;
} virus;

typedef struct link link;

struct link
{
    link *nextVirus;
    virus *vir;
};

struct fun_desc
{
    char *name;
    char (*fun)();
};




void PrintHex(unsigned char buffer[], long length){
    int i;
    for (i = 0; i < length; i++) /* output final partial buf */
        printf ("%02X ", buffer[i]);
}

void printVirus(virus* virus, FILE* output){
    fprintf(output, "Virus name: %s \n", virus->virusName);
    fprintf(output, "Virus size: %d \n", virus->SigSize);
    fprintf(output, "signatue: ");
    PrintHex(virus -> sig, virus->SigSize);
    fprintf(output, "\n");
}

virus* readVirus (FILE* file){
    virus* virus1 = calloc(1, sizeof(virus));
    //where, byte, how much' from where
    if(fread(virus1 , 1, 18, file)!=18){
        free(virus1->sig);
        free(virus1);
        return NULL;
    }
    virus1->sig = (char*)calloc(virus1->SigSize, sizeof(char));
    fread(virus1->sig, 1, virus1->SigSize, file);
    return virus1;
}

void list_print(link* virus_list, FILE* file){
    link* v = virus_list;
    while (v!=NULL)
    {
        printVirus(v->vir, file);
        v=v->nextVirus;
    }
}

link* list_append (link* virus_list, virus* data){
    /*
    add new limk to the end of the list
    */
   link* newLink = calloc (1, sizeof(link));
   newLink -> vir = data;
   newLink -> nextVirus = NULL;
   link* beginning = virus_list;
   link* current = virus_list;
   link* prev = NULL;

   if(virus_list ==NULL){
       return newLink;
   }
   else
   {
       while (current!=NULL)
       {
           prev = current;
           current = current ->nextVirus;
       }
       prev ->nextVirus = newLink;
       return beginning;
       
   }
}


void list_free (link* virus_list){
    link* v = virus_list;
    while (v!=NULL)
    {
        free(v->vir->sig);
        free(v->vir);
        link* temp = v;
        v = v->nextVirus;
        free(temp);
    }
}

void loadSignatures (char* fileName, link** virusList){
    FILE* f = fopen(fileName, "rb");
    virus* v = readVirus(f);
    while (v!=NULL)
    {
        *virusList = list_append (*virusList, v);
        v = readVirus(f);
    }
    fclose(f);
}





int main(int argc, char **argv) {
    
    char fileName[256];
    int bounds = 0, choosenOption =0;
    link* virusList = NULL;
    struct fun_desc menu [4] = {{"Load signatures", loadSignatures} , {"Print signatures", list_print}, {"Quit", NULL}, {NULL,NULL} };
    printf("Please choose a function: \n");
    for (int i = 0; i < menu[i].name; i++)
    {
        printf("%d) %s\n", (i+1), menu[i].name);
        bounds++;
    }
    printf("Choose option: ");
    scanf("%d", &choosenOption);
    while (choosenOption<bounds && choosenOption>=0)    //in bounds
    {
        if (choosenOption == 1)
        {
            getchar();
            gets(fileName);
            list_free(virusList);
            menu[choosenOption - 1].fun(fileName, &virusList);
        }
        else if(choosenOption == 2)
        {
            menu[choosenOption - 1].fun(virusList, stdout);
        }
        else if (choosenOption == 3)
        {
            break;
        }
        printf("Done\n\n");
        for (int i = 0; i < menu[i].name; i++)
        {
            printf("%d) %s\n", (i+1), menu[i].name);
        }
        printf("Choose Option: ");
        scanf("%d", &choosenOption);        
    }
    list_free(virusList);
    return 0;
}
