#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include<sys/time.h>
#include<timestamps.h>
#include "snappy-c.h"

#define MAXBUFSIZE 512*1024*1024

int main(int argc, char *argv[])
{
    FILE *f;
    char *inbuf;
    char *outbuf;
    size_t insize;
    size_t compsize;
    size_t decompsize;
    snappy_status ret;
    timestamp_t start_timestamp = timestamp();
    print_timestamp("snappy start", start_timestamp);
    inbuf = (char *)malloc(MAXBUFSIZE);
    outbuf = (char *)malloc(MAXBUFSIZE);

    memset(inbuf, 0, MAXBUFSIZE);
    memset(outbuf, 0, MAXBUFSIZE);

    #if 1
    for (int i = 0; i < MAXBUFSIZE; i += 3) {
        inbuf[i] = i % 26;
    }
    #else
    //f = fopen("/dev/urandom", "r");
    //fread(inbuf, MAXBUFSIZE, 1, f);
    //fclose(f);
    #endif
    timestamp_t start_time = timestamp();
    compsize = snappy_max_compressed_length(MAXBUFSIZE);
    ret = snappy_compress(inbuf, MAXBUFSIZE, outbuf, &compsize);
    if (ret != SNAPPY_OK)
        printf("Compression failed\n");
    else
        printf("Compression passed\n");

    snappy_uncompressed_length(outbuf, compsize, &decompsize);
    ret = snappy_uncompress(outbuf, compsize, inbuf, &decompsize);
    if (ret != SNAPPY_OK)
        printf("Uncompression failed\n");
    else
        printf("Uncompression passed\n");
    timeduration_t elapsed = time_since(start_time);
    print_elapsed_time("snappy", elapsed);
    printf("Input data size: %d\n", MAXBUFSIZE);
    printf("Compressed data size: %zu\n", compsize);
    printf("Uncompressed data size: %zu\n", decompsize);
}
