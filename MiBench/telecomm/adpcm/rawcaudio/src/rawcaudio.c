/* testc - Test adpcm coder */

#include "adpcm.h"
#include <stdio.h>
#include <time.h>

struct adpcm_state state;

#define NSAMPLES 1000

char    abuf[NSAMPLES/2];
short   sbuf[NSAMPLES];

int main() {
    int n;
    clock_t start_main, end_main;
    clock_t start, end;

    start = clock();
    double cpu_time_used_main;

    start_main = clock();  // Start timestamp for the main
    while(1) {
        n = read(0, sbuf, NSAMPLES*2);
        if ( n < 0 ) {
            perror("input file");
            exit(1);
        }
        if ( n == 0 ) break;
        adpcm_coder(sbuf, abuf, n/2, &state);
        write(1, abuf, n/4);
    }
    end = clock();

    fprintf(stderr, "Final valprev=%d, index=%d\n",
            state.valprev, state.index);

    double cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("Time taken: %.2f seconds\n", cpu_time_used);
    end_main = clock();  // End timestamp for the main function
    cpu_time_used_main = ((double)(end_main - start_main)) / CLOCKS_PER_SEC;
    printf("Total time taken for startup: %.2f seconds\n", cpu_time_used_main);
    exit(0);
}
