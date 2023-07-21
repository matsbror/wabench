#include <time.h>
#include <stdio.h>
#include <stdlib.h>

#define CYCLES 0
#define MILLIS 1
static int mode = MILLIS;

typedef unsigned long long timestamp_t;
typedef long timeduration_t; 

void init_timestamps(int new_mode) {
    mode = new_mode;
}

// returns a timestamp in ms since epoch or clock cycles
timestamp_t timestamp() {
    struct timespec ts;

    if (clock_gettime(CLOCK_REALTIME, &ts) < 0) {
        fprintf(stderr, "Could not retrieve correct timestamp");
        exit(-1);
    }

    timestamp_t millis_s = ts.tv_sec * 1000;
    timestamp_t millis_ns = ts.tv_nsec / 1000000;
    return millis_s + millis_ns; 
}

// returns the time since the last time stamp
timeduration_t time_since(timestamp_t ts1){
    timestamp_t ts2 = timestamp();
    return ts2-ts1;
}

void print_timestamp(FILE *f, const char * tag, timestamp_t ts){
    fprintf(f, "%s, timestamp: %llu\n", tag, ts);
}

void print_elapsed_time(FILE *f, const char * tag, timeduration_t time){
    fprintf(f, "%s, elapsed time: %ld\n", tag, time);
}
