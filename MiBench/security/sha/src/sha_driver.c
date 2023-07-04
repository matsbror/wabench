#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "sha.h"

int main(int argc, char **argv)
{
    FILE *fin;
    SHA_INFO sha_info;
    clock_t start, end;

    if (argc < 2)
    {
        fin = stdin;

        start = clock();
        sha_stream(&sha_info, fin);
        end = clock();
        sha_print(&sha_info);
    }
    else
    {
        while (--argc)
        {
            fin = fopen(*(++argv), "rb");
            if (fin == NULL)
            {
                printf("error opening %s for reading\n", *argv);
            }
            else
            {
                start = clock();
                sha_stream(&sha_info, fin);
                end = clock();
                sha_print(&sha_info);
                fclose(fin);
            }
        }
    }

    double cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("Time taken: %.2f seconds\n", cpu_time_used);

    return 0;
}
