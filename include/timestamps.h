#include <time.h>
#include <stdio.h>
#include <stdlib.h>

#define CYCLES 0
#define MILLIS 1
static int mode = MILLIS;

void init_timestamps(int new_mode) {
    mode = new_mode;
}

// returns a timestamp in ms since epoch or clock cycles
unsigned long timestamp() {
    struct timespec ts;

    if (clock_gettime(CLOCK_REALTIME, &ts) < 0) {
        fprintf(stderr, "Could not retrieve correct timestamp");
        exit(-1);
    }

    return ts.tv_sec * 1000 + ts.tv_nsec / 1000000; 
}

// returns the time since the last time stamp
unsigned long time_since(unsigned long ts1){
    unsigned long ts2 = timestamp();
    return ts2-ts1;
}

void print_timestamp(FILE *f, char * tag, unsigned long ts){
    fprintf(f, "%s, timestamp: %lu\n", tag, ts);
}

void print_elapsed_time(FILE *f, char * tag, unsigned long time){
    fprintf(f, "%s, elapsed time: %lu\n", tag, time);
}