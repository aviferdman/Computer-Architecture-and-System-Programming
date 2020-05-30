#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct virus {
    unsigned short SigSize;
    char virusName[16];
    char* sig;
} virus;

typedef struct link link;

struct link {
    link *nextVirus;
    virus *vir;
};

struct fun_desc {
    char *name;
    char (*fun)();
};

void PrintHex(unsigned char buffer[], long length){
    int i;
    for (i = 0; i < length; i++)
        printf ("%X ", buffer[i]);
}

void printVirus (virus* virus, FILE* output){
    fprintf(output, "Virus name: %s \n", virus->virusName);
    fprintf(output, "Virus size: %d \n", virus->SigSize);
    fprintf(output, "signature: ");
    PrintHex(virus->sig, virus->SigSize);
    fprintf(output, "\n");
}

virus* readVirus(FILE* file){
    virus* virus1 = calloc(1, sizeof(virus));
    //where, byte, how much, from where
    if (fread (virus1,1,18, file)!=18){
        free(virus1->sig);
        free(virus1);
        return NULL;
    }
    virus1->sig = (char *) calloc(virus1->SigSize , sizeof(char));
    fread (virus1->sig,1 , virus1->SigSize, file);
    return virus1;
}

void list_print(link *virus_list, FILE* file){
    link* v = virus_list;
    while (v){
        printVirus(v->vir, file);
        v = v->nextVirus;
    }
}


link* list_append(link* virus_list, virus* data) {

    //add to the end:
    link* newLink = calloc(1, sizeof(link));
    newLink -> vir = data;
    newLink -> nextVirus = NULL;
    link* beginning = virus_list;
    link* current = virus_list;
    link *prev = NULL;

    if (virus_list == NULL) {
        return newLink;
    } else {
        while (current){
            prev = current;
            current = current -> nextVirus;
        }
        prev -> nextVirus = newLink;
        return beginning;
    }
}

void list_free(link *virus_list){ /* Free the memory allocated by the list. */
    link* v = virus_list;
    while (v){
        free(v->vir->sig);
        free(v->vir);
        link* temp = v;
        v = v-> nextVirus;
        free(temp);
    }
}

void loadSignatures(char* fileName, link** virusList){
    FILE* f = fopen(fileName, "rb");
    virus* v = readVirus(f);
    while (v){
        *virusList = list_append(*virusList,v);
        v = readVirus(f);
    }
    fclose(f);
}

void detect_virus(char *buffer, unsigned int size, link *virus_list){
    int index = 0;
    while (virus_list) {
        while (index <= size - virus_list->vir->SigSize) {
            if (!memcmp(virus_list->vir->sig, &buffer[index], virus_list->vir->SigSize)) {
                printf("Starting byte location: %d\nThe virus name is: %s\nThe virus signature is: ",index,
                       virus_list->vir->virusName);
                PrintHex(virus_list->vir->sig, virus_list->vir->SigSize);
                printf("\n");
                break;
            }
            index ++;
        }
        index = 0;
        virus_list = virus_list -> nextVirus;
    }
}

int main(int argc, char **argv) {

    char fileName[30], * buffer = calloc(2<<10, sizeof(char));
    int bounds = 0, choosenOption = 0, fileSize;
    unsigned int min =0;
    FILE* file;
    link* virusList = NULL;
    struct fun_desc menu[5] = { { "Load signatures", loadSignatures }, { "Print signatures",  list_print }, { "Detect viruses", detect_virus }, { "Quit", NULL },{ NULL, NULL }};

    printf("Please choose a function:\n");
    for (int i = 0; menu[i].name; i++)
    {
        printf("%d) %s\n",(i+1),menu[i].name);
        bounds++;
    }
    printf("Choose Option: ");
    scanf("%d", &choosenOption);
    while (choosenOption<bounds && choosenOption >=0) //in bounds
    {
        if (choosenOption == 1) {
            getchar();
            gets(fileName);
            list_free(virusList);
            menu[choosenOption - 1].fun(fileName, &virusList);
        }
        else if (choosenOption == 2){
            menu[choosenOption - 1].fun(virusList, stdout);
        }
        else if (choosenOption == 3){
            file = fopen(argv[1], "rb");
            fseek(file, 0, SEEK_END); // seek to end of file
            fileSize = ftell(file); // get current file pointer
            rewind(file);
            //fseek(file, 0, SEEK_SET);
            min = fileSize <2<<10?fileSize :2<<10;
            fread (buffer,1,min, file);
            menu[choosenOption - 1].fun(buffer, fileSize , virusList);
            fclose(file);
        }
        else if (choosenOption == 4){
            break;
        }
        printf("Done\n\n");
        for (int i = 0; menu[i].name; i++)
        {
            printf("%d) %s\n",(i+1),menu[i].name);
        }
        printf("Choose Option: ");
        scanf("%d", &choosenOption);
    }
    free(buffer);
    list_free(virusList);
}
