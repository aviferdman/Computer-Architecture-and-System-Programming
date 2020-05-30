#include <stdio.h>
#include <stdlib.h>
#include <string.h>



int main(int argc, char**argv) {

    FILE * output=stdout;
    FILE* input = stdin;
    int containsD = 0;
    int containsEPositive = 0;
    int containsENegative = 0;
    char *encoder1 = NULL;
    int mod = 0;
    int containsO = 0;
    int error = 0;
    char myChar =  EOF;
    int k,i,oldValue,newValue,temp2,temp3;
    //update flags
    for(k=1; k<argc; k++) {
        //update D flag
        if (strcmp(argv[k], "-D") == 0){
            containsD = 1;
        }
            //update e flag
        else if ((argv[k][0]=='+'|argv[k][0]=='-')&&argv[k][1]=='e'){
            //+
            if(argv[k][0]=='+'){
                containsEPositive = 1;
            }
                //-
            else{
                containsENegative = 1;
            }
            encoder1 = &argv[k][2];
            mod = strlen(argv[k])-2;
        }
        else if (argv[k][0]=='-'&&argv[k][1]=='o') {
            output = fopen(&argv[k][2], "w"); //need to decide what file to open
            containsO = 1;
        }

        else{	//if no other flag than its an error
            error = 1;
        }
    }
    //print the arguments
    if (containsD & !error){
        for(k=1; k<argc; k++) {
            fprintf(stderr,"%s", argv[k]);
            fprintf(stderr, " ");
        }
        fprintf(stderr, "\n");
    }
    if(!error){
        myChar = fgetc(input);
    }
    i = 0;
    while(myChar != EOF && !error){
        if(myChar == '\n'){
            i=0;
        }
        else if (feof(stdin)){
            break;
        }
        else {
            oldValue = myChar;
            newValue = oldValue;
            temp2 = 0;
            temp3 = 0; //to calculate the mod if needed
            if ((unsigned) containsENegative | (unsigned) containsEPositive) {    //calculating mod
                temp2 = i % (mod);
                i = i + 1;
                temp3 = encoder1[temp2] - '0';
            }
            if (containsENegative) {
                newValue = oldValue - temp3;
            } else if (containsEPositive) {
                newValue = oldValue + temp3;
            } else if ('a' <= oldValue & 'z' >= oldValue) {
                newValue = 'A' + oldValue - 'a';
            }
            myChar = (char) newValue;
            if (containsD) { //DEBUG MODE ACTIVATED
                fprintf(stderr, "%d\t%d\n", oldValue, newValue);
            }
        }
        fprintf(output,"%c",myChar);
        myChar = fgetc (input);

    }
    if (containsO & !error){
        fclose(output);
    }
    if (error){
        printf("%s", "An error occurred\n");
    }
}