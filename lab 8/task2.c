#include <elf.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#define ON 1
#define OFF 0
#define NO_FILE -1

int debug_mode = OFF; //indicates debug mode
int current_fd = NO_FILE; //indicates if a valid file is open or not
void * map_start = NULL; //the mapping address of the current open file
off_t current_fd_size=0;

typedef struct{
    char *name;
    void (*f)();
}menu;

//=================================
//Declare all functions here!
void quit();
void examineElfFile();
void toggleDebugMode();
char checkIfElf(unsigned char b1,unsigned char b2,unsigned char b3);
void printEIData(unsigned char x);
void printSectionNames();
void printSymbols();
//=================================


int main(int argc, char * argv[]){
    int bounds = 0;
    int selected = 0;
    menu menu_opts[] = {{"Toggle Debug Mode",toggleDebugMode},{"Examine ELF File",examineElfFile},
                        {"Print Section Names",printSectionNames},{"Print Symbols",printSymbols},{"Quit",quit},{NULL,NULL}};
    printf("Please choose a function:\n");
    for (int i = 0; menu_opts[i].name!=NULL; i++)
    {
        printf("%d-%s\n",i,menu_opts[i].name);
        bounds++;
    }
    printf("Option: ");
    scanf("%d", &selected);
    while (selected<bounds && selected >=0) //in bounds
    {
        getchar();
        menu_opts[selected].f();
        for (int i = 0; menu_opts[i].name!=NULL; i++)
        {
            printf("%d) %s\n",i,menu_opts[i].name);
        }
        printf("Option: ");
        scanf("%d", &selected);
    }
    return 0;
}


void quit(){
    exit(0);
}

void toggleDebugMode(){
    debug_mode = ON;
}

/*
If invoked on an ELF file,
examine should initialize a global file descriptor variable Currentfd for this file,
and leave the file open.
When invoked on a non-ELF file, or the file cannot be opened or mapped at all:
you should print an error message,
unmap the file (if already mapped) close the file (if already open),
and set Currentfd to -1 to indicate no valid file.
*/
void examineElfFile(){
    FILE * toOpen = NULL;
    int err=0;
    char file_name[100];
    struct stat fd_stat;
    Elf32_Ehdr *header;
    //prompt for filename
    printf("Enter file name: ");
    scanf("%s",file_name);
    //close open file in Currentfd
    if(current_fd != NO_FILE){
        err = close(current_fd);
        if(err < 0){
            printf("couldn't close file indicated by fd: %d\n",current_fd);
            err = 0; //set it back to non error indication
        }else{
            munmap(map_start, current_fd_size);
        }
    }
    toOpen = fopen(file_name,"r"); //open for reading only
    if(!toOpen){
        printf("couldn't open file specified: %s\n",file_name);
        current_fd = NO_FILE; //indicate no valid file
        return; //now we have to return from the function, we have no file to work with.
    }
    current_fd = fileno(toOpen); //get the fd from the file opened
    //notice: if a file is an elf, 4 first bytes: \x7fELF --> (hex) 7f 45 4c 46
    if( fstat(current_fd, &fd_stat) != 0) {
        perror("stat failed");
        return;
    }
    current_fd_size = fd_stat.st_size;
    if ((map_start = mmap(NULL, fd_stat.st_size, PROT_READ, MAP_SHARED, current_fd, 0)) == MAP_FAILED) {
        perror("mmap failed");
        return;
    }

    header = (Elf32_Ehdr *) map_start;
    //print bytes 1,2,3:
    printf("First three bytes of file: ");
    for(int i=1;i<4;i++){
        printf("%X ",header->e_ident[i]);
    }
    printf("\n");
    //if not an elf file, cancel
    if(!checkIfElf(header->e_ident[1],header->e_ident[2],header->e_ident[3])){
        printf("Not an elf file!\n");
        return;
    }
    //print The data encoding scheme of the object file.
    printEIData(header->e_ident[EI_DATA]);
    //print entry point
    printf("Entry point: %X \n",header->e_entry);
    //print The file offset in which the section header table resides.
    printf("File offset in section header: %X\n",header->e_shoff);
    //print the number of section headers
    printf("Number of section headers: %X\n",header->e_shnum);
    //print the size of each section header entry.
    printf("Sections headers size:(all have same size) %X\n",header->e_shentsize);
    //print the file offset in which the program header table resides.
    printf("File offset in program header: %X\n",header->e_phoff);
    //print the number of program header entries.
    printf("Number of program header entries: %X\n",header->e_phnum);
    //print the size of each program header entry.
    printf("Program headers size:(all have same size) %X\n",header->e_phentsize);
}

char checkIfElf(unsigned char b1,unsigned char b2,unsigned char b3){
    if((b1 == 0x45)&&(b2 == 0x4c)&&(b3 == 0x46))
        return 1; //true
    return 0; //false
}

void printEIData(unsigned char x){
    x == ELFDATA2LSB ? printf("Data content: Two's complement, little-endian.\n") :
    x == ELFDATA2MSB ? printf("Data content: Two's complement, big-endian.\n") :
    printf("Data content: Unknown data format.\n");
}

void printSectionNames(){
    Elf32_Ehdr * header;
    Elf32_Shdr * sectionHeaders;
    char * stringTable;
    if(current_fd == NO_FILE){
        printf("Invalid file!\n");
        return;
    }
    header = (Elf32_Ehdr *) map_start;
    sectionHeaders = (Elf32_Shdr *)(map_start + header->e_shoff); //get a pointer to section headers
    stringTable = (char *)(map_start + sectionHeaders[header->e_shstrndx].sh_offset);
    //now stringTable holds the pointer to the beggining of where all names resides.
    if(debug_mode==ON){printf("section headers string table offset: %X\n",header->e_shstrndx);}
    printf("idx name\t\t\taddress\t\t\toffset\t\tsize\t\ttype\n");
    for(int i=0;i<header->e_shnum;i++){
        printf("%d %-15s\t\t%08X\t\t%06X\t\t%06X\t\t%X\n",i,stringTable+sectionHeaders[i].sh_name,
               sectionHeaders[i].sh_addr,
               sectionHeaders[i].sh_offset,sectionHeaders[i].sh_size,
               sectionHeaders[i].sh_type);
    }
}


void printSymbols(){
    int  i, j;
    Elf32_Ehdr *header; /* this will point to the header structure */
    Elf32_Shdr * sectionHeaders;
    Elf32_Sym *sym;
    header = (Elf32_Ehdr *) map_start;
    int eShnum = header->e_shnum;
    char * stringTable = NULL;
    char * sectionHeadersStringTable = NULL;
    sectionHeaders = (Elf32_Shdr *)(map_start + header->e_shoff); //get a pointer to section headers
    stringTable = (char *)(map_start + sectionHeaders[header->e_shstrndx].sh_offset);
    sectionHeadersStringTable = (char *)(map_start + sectionHeaders[header->e_shstrndx].sh_offset);
    char * secName ="";
    for (i = 0; i < eShnum; ++i) {
        if(strcmp(sectionHeadersStringTable+sectionHeaders[i].sh_name,".strtab")==0){
            stringTable = (char *)(map_start + sectionHeaders[i].sh_offset);
        }
    }
    for (i = 0; i < eShnum; ++i) {
        if ((sectionHeaders[i].sh_type == SHT_SYMTAB)||(sectionHeaders[i].sh_type==SHT_DYNSYM)){ //if a symbol table exists
            sym = (Elf32_Sym *)(map_start + sectionHeaders[i].sh_offset); //get a pointer to symbol table
            if(debug_mode == ON){
                printf("symbol table size:(hex) %X\n",sectionHeaders[i].sh_size);
                printf("Number of symbols:(hex) %X\n",(sectionHeaders[i].sh_size/sectionHeaders[i].sh_entsize));
            }
            /*[index]
            * value
            * section_index
            * section_name
            * symbol_name*/
            printf("idx\t\t\tvalue\t\tsection_index\t\tsection_name\t\tsymbol_name\n");
            for(j=0;j<(sectionHeaders[i].sh_size/sectionHeaders[i].sh_entsize);j++){
                if(sym[j].st_shndx == 0)
                    secName = "UND"; 
                else if(sym[j].st_shndx < eShnum)
                    
                    //secName = (stringTable+sectionHeaders[sym[j].st_shndx].sh_name);
                    secName = sectionHeadersStringTable + sectionHeaders[sym[j].st_shndx].sh_name;
                else if(sym[j].st_shndx == 65521)
                    secName ="ABS";
                else
                    secName = "COM";
                
                printf("%d.\t\t\t%-15X\t%-15hd\t\t%-15s\t\t%-15s\n",
                       j, sym[j].st_value,
                       sym[j].st_shndx,
                       secName,
                       stringTable + sym[j].st_name);
            }
        }
    }
}
