
#include <stdio.h>

char c_checkValidity(int x,int y);
extern int assFunc(int,int);

int main(int argc, char **argv){
    int x,y;
    scanf("%d%d",&x,&y);
    assFunc(x,y);
}

char c_checkValidity(int x, int y){

    if(x>=y)
        return '1';

    return '0';
}