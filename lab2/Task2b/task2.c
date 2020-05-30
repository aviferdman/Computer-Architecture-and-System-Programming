#include <stdlib.h>
#include <stdio.h>
#include <string.h>
 

//2b
char encrypt(char c); /* Gets a char c and returns its encrypted form by adding 3 to its value. 
          If c is not between 0x20 and 0x7E it is returned unchanged */
char decrypt(char c); /* Gets a char c and returns its decrypted form by reducing 3 to its value. 
            If c is not between 0x20 and 0x7E it is returned unchanged */
char dprt(char c); /* dprt prints the value of c in a decimal representation followed by a 
           new line, and returns c unchanged. */
char cprt(char c); /* If c is a number between 0x20 and 0x7E, cprt prints the character of ASCII value c followed 
                    by a new line. Otherwise, cprt prints the dot ('.') character. After printing, cprt returns 
                    the value of c unchanged. */
char my_get(char c); /* Ignores c, reads and returns a character from stdin using fgetc. */

char censor(char c) {
  if(c == '!')
    return '.';
  else
    return c;
}
 
 //2a
char* map(char *array, int array_length, char (*f) (char)){
  char* mapped_array = (char*)(malloc(array_length*sizeof(char)));
  for (int i = 0; i < array_length; i++)
  {
      mapped_array[i] = f(array[i]);
  }
  
  return mapped_array;
}
 
int main(int argc, char **argv){
    char arr1[] = {'H','E','Y','!'};
    char* arr2 = map(arr1, 4, censor);
    printf("%s\n", arr2); 
    printf("%c", encrypt('g'));
    free(arr2);
}


char encrypt(char c){
  if( c >= 0x20 && c <= 0x7e) {
  // c is in range
    c=c+3;
  }
  return c;
}
char decrypt(char c){
  if( c >= 0x20 && c <= 0x7e) {
  // c is in the range
    c=c-3;
  }
  return c;
}
char dprt(char c){
  printf("%d\n",c);
  return c;
}
char cprt(char c){
  if( c >= 0x20 && c <= 0x7e) {
  // c is in the range
    printf("%c\n", c);
  }
  else
  {
    printf(".\n");
  }
  return c;
}
char my_get(char c){
  return fgetc(stdin);
}
