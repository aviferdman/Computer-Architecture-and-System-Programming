#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int addr5;
int addr6;

int foo();
void point_at(void *p);
void foo1();
void foo2();

int main (int argc, char** argv){
    int addr2;
    int addr3;
    char* yos="ree";
    int * addr4 = (int*)(malloc(50));
    //int iarray[3];
    float farray[3];
    double darray[3];
    //char carray[3];

    //code I added
    int iarray[] = {1,2,3};
    char carray[] = {'a','b','c'};
    int* iarrayPtr = iarray;
    char* carrayPtr = carray;
    char* uninitialized;
    for (int i = 0; i < 3; i++)
    {
        printf("the value in index %d in iarray is: %d\n", i,*iarrayPtr+i);
        printf("the value in index %d in carray is: %c\n", i,*carrayPtr+i);
    }
    printf("the address of the uninitialized ptr is: %p\n", &uninitialized);
    //


    //printf("hx of iarray is: %x\n", iarray);
    //printf("hx of iarray + 1 is: %x\n", iarray+1);//the size of int is 4 bytes
    printf("hx of farray is: %x\n", farray);
    printf("hx of farray + 1 is: %x\n", farray+1);//the size of float is 4 bytes
    printf("hx of darray is: %x\n", darray);
    printf("hx of darray + 1 is: %x\n", darray+1);//the size of int is 8 bytes
    //printf("hx of carray is: %x\n", carray);
    //printf("hx of carray + 1 is: %x\n", carray+1);//the size of int is 1 bytes

    printf("- &addr2: %p\n",&addr2);
    printf("- &addr3: %p\n",&addr3);
    printf("- foo: %p\n",foo);
    printf("- &addr5: %p\n",&addr5);
    
	point_at(&addr5);
	
    printf("- &addr6: %p\n",&addr6);
    printf("- yos: %p\n",yos);
    printf("- addr4: %p\n",addr4);
    printf("- &addr4: %p\n",&addr4);
    
    printf("- &foo1: %p\n" ,&foo1);
    printf("- &foo1: %p\n" ,&foo2);
    printf("- &foo2 - &foo1: %ld\n" ,&foo2 - &foo1);
    return 0;
}

int foo(){
    return -1;
}

void point_at(void *p){
    int local;
	static int addr0 = 2;
    static int addr1;


    long dist1 = (size_t)&addr6 - (size_t)p;
    long dist2 = (size_t)&local - (size_t)p;
    long dist3 = (size_t)&foo - (size_t)p;
    
    printf("the size of long is: %d\n" , sizeof(long));//the long is 4 bytes
    printf("the size of int is: %d\n" , sizeof(int));//the int is 4 bytes

    printf("dist1: (size_t)&addr6 - (size_t)p: %ld\n",dist1);
    printf("dist2: (size_t)&local - (size_t)p: %ld\n",dist2);
    printf("dist3: (size_t)&foo - (size_t)p:  %ld\n",dist3);
	
	printf("- addr0: %p\n", & addr0);
    printf("- addr1: %p\n",&addr1);
}

void foo1 (){    
    printf("foo1\n"); 
}

void foo2 (){    
    printf("foo2\n");    
}
