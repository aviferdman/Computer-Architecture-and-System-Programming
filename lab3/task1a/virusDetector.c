#include <stdio.h>
#include <stdlib.h>

typedef struct virus
{
    unsigned short SigSize;
    char virusName [16];
    char* sig;
} virus;

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
    virus* virus1 = malloc(sizeof(virus));
    //where, byte, how much' from where
    if(fread(virus1 , 1, 18, file)!=18){
        free(virus1->sig);
        free(virus1);
        return NULL;
    }
    virus1->sig = (char*)malloc(virus1->SigSize*sizeof(char));
    fread(virus1->sig, 1, virus1->SigSize, file);
    return virus1;
}

int main(int argc, char **argv) {
    
    FILE* f = fopen (argv[1], "rb");
    virus* v = readVirus(f);
    while (v){
        printVirus(v, stdout);
        free(v->sig);
        free(v);
        v = readVirus(f);
    }
    fclose(f);
    
    return 0;
}
