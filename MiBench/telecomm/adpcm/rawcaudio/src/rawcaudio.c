/* testc - Test adpcm coder */

#include "adpcm.h"
#include <stdio.h>
#include <sys/time.h>
#include <timestamps.h>
struct adpcm_state state;

#define NSAMPLES 1000

char	abuf[NSAMPLES/2];
short	sbuf[NSAMPLES];

int main() {
    int n;
	timestamp_t start_timestamp= timestamp();
    print_timestamp(stdout, "rawcaudio_start", start_timestamp);

    while(1) {
	n = read(0, sbuf, NSAMPLES*2);
	if ( n < 0 ) {
	    perror("input file");
	    exit(1);
	}
	if ( n == 0 ) break;
	timestamp_t start_time = timestamp();
	adpcm_coder(sbuf, abuf, n/2, &state);
	write(1, abuf, n/4);
	timeduration_t elapsed = time_since(start_time);
    print_elapsed_time(stdout, "rawcaudio\0", (double)elapsed);
    }
    fprintf(stderr, "Final valprev=%d, index=%d\n",
	    state.valprev, state.index);
    exit(0);
}
