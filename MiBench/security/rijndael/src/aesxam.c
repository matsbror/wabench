#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <ctype.h>
#include <time.h>

#include "aes.h"

int main(int argc, char *argv[])
{
    FILE *fin = NULL, *fout = NULL;
    char *cp, ch, key[32];
    int i = 0, by = 0, key_len = 0, err = 0;
    aes ctx[1];
    clock_t start, end;

    if (argc != 5 || (toupper(*argv[3]) != 'D' && toupper(*argv[3]) != 'E'))
    {
        printf("usage: rijndael in_filename out_filename [d/e] key_in_hex\n");
        err = -1;
        goto exit;
    }

    cp = argv[4]; /* this is a pointer to the hexadecimal key digits  */
    i = 0;        /* this is a count for the input digits processed   */

    while (i < 64 && *cp) /* the maximum key length is 32 bytes and   */
    {                     /* hence at most 64 hexadecimal digits      */
        ch = toupper(*cp++); /* process a hexadecimal digit  */
        if (ch >= '0' && ch <= '9')
            by = (by << 4) + ch - '0';
        else if (ch >= 'A' && ch <= 'F')
            by = (by << 4) + ch - 'A' + 10;
        else /* error if not hexadecimal     */
        {
            printf("key must be in hexadecimal notation\n");
            err = -2;
            goto exit;
        }

        /* store a key byte for each pair of hexadecimal digits         */
        if (i++ & 1)
            key[i / 2 - 1] = by & 0xff;
    }

    if (*cp)
    {
        printf("The key value is too long\n");
        err = -3;
        goto exit;
    }
    else if (i < 32 || (i & 15))
    {
        printf("The key length must be 32, 48 or 64 hexadecimal digits\n");
        err = -4;
        goto exit;
    }

    key_len = i / 2;

    if (!(fin = fopen(argv[1], "rb"))) /* try to open the input file */
    {
        printf("The input file: %s could not be opened\n", argv[1]);
        err = -5;
        goto exit;
    }

    if (!(fout = fopen(argv[2], "wb"))) /* try to open the output file */
    {
        printf("The output file: %s could not be opened\n", argv[1]);
        err = -6;
        goto exit;
    }

    if (toupper(*argv[3]) == 'E')
    { /* encryption in Cipher Block Chaining mode */
        set_key(key, key_len, enc, ctx);

        start = clock();
        err = encfile(fin, fout, ctx, argv[1]);
        end = clock();
    }
    else
    { /* decryption in Cipher Block Chaining mode */
        set_key(key, key_len, dec, ctx);

        start = clock();
        err = decfile(fin, fout, ctx, argv[1], argv[2]);
        end = clock();
    }

exit:
    if (fout)
        fclose(fout);
    if (fin)
        fclose(fin);

    double cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("Time taken: %.2f seconds\n", cpu_time_used);

    return err;
}
