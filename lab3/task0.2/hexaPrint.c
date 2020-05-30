#include <stdio.h>
#include <stdlib.h>

#define BUFSZ 1

int main(int argc, char **argv) {
   unsigned char buf[BUFSZ];
    long bytes = 0, readsz = sizeof buf;
    FILE *fp = argc > 1 ? fopen (argv[1], "rb") : stdin;

    if (!fp) {
        fprintf (stderr, "error: file open failed '%s'.\n", argv[1]);
        return 1;
    }

    /* read/output BUFSZ bytes at a time */
    bytes = fread (buf, sizeof *buf, readsz, fp);
    //while ((bytes = fread (buf, sizeof *buf, readsz, fp)) == readsz) {
    //    for (i = 0; i < readsz; i++)
    //        printf ("%x ", buf[i]);
    //    putchar ('\n');
    //}
    //for (i = 0; i < bytes; i++) /* output final partial buf */
    //    printf ("%x ", buf[i]);
    //putchar ('\n');
    while ((bytes = fread (buf, sizeof *buf, readsz, fp)) == readsz) {
        PrintHex(buf, bytes);
    }
    putchar ('\n');

    if (fp != stdin)
        fclose (fp);

    return 0;
}

void PrintHex(unsigned char buffer[], long length){
    int i;
    for (i = 0; i < length; i++) /* output final partial buf */
        printf ("%02X ", buffer[i]);
}