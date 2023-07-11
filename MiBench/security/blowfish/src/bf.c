#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include "blowfish.h"

int main(int argc, char *argv[]) {
    clock_t start, end;
    double cpu_time_used;
    clock_t start_main, end_main;
    double cpu_time_used_main;
    BF_KEY key;
    unsigned char ukey[8];
    unsigned char indata[40], outdata[40], ivec[8];
    int num;
    int by = 0, i = 0;
    int encordec = -1;
    char *cp, ch;
    FILE *fp, *fp2;
    start_main = clock();  // Start timestamp for the main
    if (argc < 3) {
        printf("Usage: blowfish {e|d} <intput> <output> key\n");
        exit(-1);
    }

    if (*argv[1] == 'e' || *argv[1] == 'E')
        encordec = 1;
    else if (*argv[1] == 'd' || *argv[1] == 'D')
        encordec = 0;
    else {
        printf("Usage: blowfish {e|d} <intput> <output> key\n");
        exit(-1);
    }

    /* Read the key */
    cp = argv[4];
    while (i < 64 && *cp) /* the maximum key length is 32 bytes and   */
    {                     /* hence at most 64 hexadecimal digits      */
        ch = toupper(*cp++);     /* process a hexadecimal digit  */
        if (ch >= '0' && ch <= '9')
            by = (by << 4) + ch - '0';
        else if (ch >= 'A' && ch <= 'F')
            by = (by << 4) + ch - 'A' + 10;
        else         /* error if not hexadecimal     */
        {
            printf("key must be in hexadecimal notation\n");
            exit(-1);
        }

/* store a key byte for each pair of hexadecimal digits         */
        if (i++ & 1)
            ukey[i / 2 - 1] = by & 0xff;
    }

    BF_set_key(&key, 8, ukey);

    if (*cp) {
        printf("Bad key value.\n");
        exit(-1);
    }


    /* Open the input and output files */
    if ((fp = fopen(argv[2], "r")) == 0)
     {
        printf("Usage: blowfish {e|d} <intput> <output> key\n");
        exit(-1);
    };
    if ((fp2 = fopen(argv[3], "w")) == 0) 
    {
        printf("Usage: blowfish {e|d} <intput> <output> key\n");
        exit(-1);
    };
    start = clock(); // Start timestamp
    i = 0;
    while (!feof(fp)) 
    {
        int j;
        while (!feof(fp) && i < 40)
            indata[i++] = getc(fp);

        BF_cfb64_encrypt(indata, outdata, i, &key, ivec, &num, encordec);

        for (j = 0; j < i; j++)
         {
            /*printf("%c",outdata[j]);*/
            fputc(outdata[j], fp2);
        }
        i = 0;
    }
    end = clock(); // End timestamp
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    printf("Time taken: %.2f seconds\n", cpu_time_used);
    
    fclose(fp);
    fclose(fp2);
    end_main=clock();
    cpu_time_used_main = ((double)(end_main - start_main)) / CLOCKS_PER_SEC;
    printf("Total time taken for startup: %.2f seconds\n", cpu_time_used_main);
    exit(1);
}
