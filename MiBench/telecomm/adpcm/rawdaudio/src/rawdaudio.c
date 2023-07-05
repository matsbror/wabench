/* testd - Test adpcm decoder */

#include "adpcm.h"
#include <stdio.h>
#include <time.h>

struct adpcm_state state;

#define NSAMPLES 1000

char    abuf[NSAMPLES/2];
short   sbuf[NSAMPLES];

int main() {
    int n;
    clock_t start, end;

    start = clock();

    while(1) {
        n = read(0, abuf, NSAMPLES/2);
        if ( n < 0 ) {
            perror("input file");
            exit(1);
        }
        if ( n == 0 ) break;
        adpcm_decoder(abuf, sbuf, n*2, &state);
        write(1, sbuf, n*4);
    }

    end = clock();

    fprintf(stderr, "Final valprev=%d, index=%d\n",
            state.valprev, state.index);
    double cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("Time taken: %.2f seconds\n", cpu_time_used);
    exit(0);
}
