#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define ONE_BYTE 1
#define TWO_BYTES 2
#define FOUR_BYTES 4
#define HEXA_MODE 1
#define DECIMAL_MODE 0
#define true 1
#define false 0

typedef struct {
    char debug_mode;
    char display_mode;
    char file_name[128];
    int unit_size;
    unsigned char mem_buf[10000];
    size_t mem_count;
} state;

struct fun_desc {
    char *name;
    void (*fun)(state* s);
};

void displayUnitsHEX(char *mem, state *s, int units);

void displayUnitsDEC(char *mem, state *s, int units);

void toggleDebugMode(state* s){
    if (!s->debug_mode) {
        s->debug_mode = true;
        printf("Debug flag now on\n");
    } else{
        s->debug_mode = false;
        printf("Debug flag now off\n");
    }
}

void setFileName(state* s){
    if (s) {
        printf("Enter File Name\n");
        scanf("%s", s->file_name);
    }
    if(s->debug_mode){
        printf("Debug: filename set to:%s \n",s->file_name);
    }
}

void setUnitSize(state* s){
    if (s) {
        int num;
        printf("Enter size (1/2/4)\n");
        scanf("%d", &num);
        if (num == ONE_BYTE || num == TWO_BYTES || num == FOUR_BYTES) {
            s->unit_size = num;
            if (s->debug_mode) {
                printf("Debug: set size to %d\n", num);
            }
        } else {
            printf("Invalid size\n");
        }
    }
}

void loadIntoMemory (state* s){
    FILE* file = NULL;
    char input[100];
    int location;
    int length;
    if (s)
    {
        if(strcmp(s->file_name,"")==0){
            printf("empty filename!\n");
            return;
        }
        
        file = fopen(s->file_name,"rb");
        if (file)   //file opened successfully
        {
            printf("Please enter <location> <length>\n");
            fgets(input, 100, stdin);
            sscanf(input, "%x %d\n", &location, &length);

            if (s->debug_mode == true){
                printf("Debug filename: %s\n", s->file_name);
                printf("Debug location: %x\n", location);
                printf("Debug length: %d\n", s->mem_count);
            }
            s->mem_count = length * s->unit_size;
            fseek(file, location, SEEK_SET);
            fread(s->mem_buf, s->unit_size, s->mem_count, file);
            fclose(file);
            printf("Loaded %d bytes into memory\n",s->mem_count);
        }
        else
        {
            printf("error while opening the file\n");
        }
    }
    else
    {
        printf("state is null");
    }
}

void toggleDisplayMode (state* s){
    if (s->display_mode == DECIMAL_MODE) {
        s->display_mode = HEXA_MODE;
        printf("Display flag now on, hexadecimal representation\n");
    } else{
        s->display_mode = DECIMAL_MODE;
        printf("Display flag now off, decimal representation\n");
    }
}

void memoryDispaly (state* s){
    int units, addr;
    char input[100];
    char* mem;
    if (s->display_mode == HEXA_MODE){
        printf("Hexadecimal\n");
        printf("===========\n");
        fgets(input, 100, stdin);
        sscanf(input, "%d", &units);
        fgets(input, 100, stdin);
        sscanf(input, "%X", &addr);
        if (addr!=0){
            mem = (char*)addr;
        } else{     //speacial case
            mem = (char*)s->mem_buf;
        }
        displayUnitsHEX(mem, s, units);
    }
    if (s->display_mode == DECIMAL_MODE){
        printf("Decimal\n");
        printf("=======\n");
        fgets(input, 100, stdin);
        sscanf(input, "%d", &units);
        fgets(input, 100, stdin);
        sscanf(input, "%X", &addr);
        if (addr!=0){
            mem = (char*)addr; //check this case
        } else{     //speacial case
            mem = (char*)s->mem_buf;
        }
        displayUnitsDEC(mem, s, units);
    }
}

void displayUnitsDEC(char *mem, state *s, int units) {
    int i, convert;
    for (i = 0; i < units; i=i+1) {

        convert = *((int*)(mem+(i*s->unit_size)));

        if (s->unit_size == ONE_BYTE){printf("%hhd\n", convert);}
        else if (s->unit_size == TWO_BYTES){printf("%hd\n", convert);}
        else    {printf("%d\n", convert);}
    }
}

void displayUnitsHEX(char *mem, state *s, int units) {
    int i, convert;
    for (i = 0; i < units; i=i+1) {

        convert = *((int*)(mem+(i*s->unit_size)));

        if (s->unit_size == ONE_BYTE){printf("%hhx\n", convert);}
        else if (s->unit_size == TWO_BYTES){printf("%hx\n", convert);}
        else    {printf("%x\n", convert);}

    }
}

void saveIntoFile (state* s){
    FILE* fd = NULL;
    char input[100];
    unsigned long source_address; //hexa
    unsigned long target_location; //hexa
    int length; //decimal
    long fileSize = 0;
    printf("Please enter <source-address> <target-location> <length>\n");
    fgets(input, 100, stdin);
    sscanf(input, "%lx %lx %d\n", &source_address, &target_location, &length);
    //address = (char *) (source_address != 0 ? source_address : s->mem_buf);
    fd = fopen(s->file_name, "rb+");
    if(!fd){printf("error! filename:%s \n",s->file_name);return;}
    fseek(fd, 0L, SEEK_END);
    fileSize = ftell(fd);
    if (target_location > fileSize) printf("target location is greater than file size\n");
    else if (fd){    //can open file
        fseek(fd, target_location, SEEK_SET);
        if (source_address == 0) {
            fwrite(s->mem_buf, s->unit_size, length, fd);
        }
        else{
            fwrite((char*)source_address, s->unit_size, length, fd);
        }
    }
    else{   //can't open file
        printf("couldn't open file!\n");
    }
    fclose(fd);
}

void memoryModify (state* s){
    char input[100];
    int location,value=0; //both hex vals!
    printf("Please enter <location> <val>\n");
    fgets(input,100,stdin);
    sscanf(input,"%x %x",&location,&value);
    printf("value :%d\n",value);
    if(location > 10000-4) printf("location exceeds buffer!\n");
    else{
        int * writeTo = (int*)(&s->mem_buf[location]);
        *writeTo= value; // stores the value entered from the user
    }
}

void quit (state* s){
    if (s->debug_mode){
        printf("quitting\n");
    }
    free(s);
    exit(0);
}

int main(int argc, char * argv[]){
    int bounds = 0;
    int selected = 0;
    state* state = calloc(1,sizeof(state));
    state->debug_mode = false;
    state->unit_size = ONE_BYTE;
    state->display_mode = DECIMAL_MODE;
    struct fun_desc menu[] = { { "Toggle Debug Mode", toggleDebugMode }, { "Set File Name", setFileName }, { "Set Unit Size", setUnitSize },
                               {"Load Into Memory", loadIntoMemory},{"Toggle Display Mode", toggleDisplayMode},{"Memory Display", memoryDispaly},
                               {"Save Into File", saveIntoFile},{"Memory Modify", memoryModify},{ "Quit", quit },{ NULL, NULL } };
    printf("Please choose a function:\n");
    for (int i = 0; menu[i].name!=NULL; i++)
    {
        printf("%d-%s\n",i,menu[i].name);
        bounds++;
    }
    printf("Option: ");
    scanf("%d", &selected);
    while (selected<bounds && selected >=0) //in bounds
    {
        getchar();
        menu[selected].fun(state);
        for (int i = 0; menu[i].name!=NULL; i++)
        {
            printf("%d) %s\n",i,menu[i].name);
        }
        printf("Option: ");
        scanf("%d", &selected);
    }
    return 0;
}
