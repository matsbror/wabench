/* NIST Secure Hash Algorithm */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "sha.h"
#include <sys/time.h>
#include <timestamps.h>
int main(int argc, char **argv)
{
    FILE *fin;
    SHA_INFO sha_info;
	timeduration_t accumulated_time = 0;

	timestamp_t main_timestamp = timestamp();
  	print_timestamp("main", main_timestamp);

    if (argc < 2) {
		fin = stdin;
		
		timestamp_t start_time = timestamp();
		print_timestamp("start", start_time);

		sha_stream(&sha_info, fin);
		sha_print(&sha_info);

		timestamp_t end_time = timestamp();
		print_timestamp("end", end_time);
    	accumulated_time += end_time - start_time;
    } else {
	while (--argc) {
		    fin = fopen(*(++argv), "rb");
		    if (fin == NULL) {
			printf("error opening %s for reading\n", *argv);
	    } else {
			timestamp_t start_time = timestamp();
			print_timestamp("start", start_time);
	
			sha_stream(&sha_info, fin);
			sha_print(&sha_info);
			fclose(fin);
			timestamp_t end_time = timestamp();
			print_timestamp("end", end_time);
			accumulated_time += end_time - start_time;
	    }
	}
    }
	print_elapsed_time("accumulated", accumulated_time);
    return(0);
}
