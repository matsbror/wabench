/* +++Date last modified: 05-Jul-1997 */

/*
**  BITCNTS.C - Test program for bit counting functions
**
**  public domain by Bob Stout & Auke Reitsma
*/

#include <stdio.h>
#include <stdlib.h>
#include "conio.h"
#include <limits.h>
#include <time.h>
#include <float.h>
#include "bitops.h"
#include <sys/time.h>
#include <timestamps.h>

double seconds_now() 
{
    struct timespec now;
    timespec_get(&now, TIME_UTC);
    return (now.tv_sec * 1000000000 +  now.tv_nsec) / 1000000000.0;
}

#define FUNCS  7

static int CDECL bit_shifter(long int x);

int main(int argc, char *argv[])
{
  double start, stop;
  double ct, cmin = DBL_MAX, cmax = 0;
  int i, cminix, cmaxix;
  long j, n, seed;
  int iterations;
  timestamp_t start_timestamp= timestamp();
  print_timestamp(stdout, "bitcnts_start", start_timestamp);
  static int (* CDECL pBitCntFunc[FUNCS])(long) = {
    bit_count,
    bitcount,
    ntbl_bitcnt,
    ntbl_bitcount,
    /*            btbl_bitcnt, DOESNT WORK*/
    BW_btbl_bitcount,
    AR_btbl_bitcount,
    bit_shifter
  };
  static char *text[FUNCS] = {
    "Optimized 1 bit/loop counter",
    "Ratko's mystery algorithm",
    "Recursive bit count by nybbles",
    "Non-recursive bit count by nybbles",
    /*            "Recursive bit count by bytes",*/
    "Non-recursive bit count by bytes (BW)",
    "Non-recursive bit count by bytes (AR)",
    "Shift and count bits"
  };
  if (argc<2) {
    fprintf(stderr,"Usage: bitcnts <iterations>\n");
    exit(-1);
	}
  iterations=atoi(argv[1]);
  
  puts("Bit counter algorithm benchmark\n");
  for (i = 0; i < FUNCS; i++) {
    start = seconds_now();
    timestamp_t start_time = timestamp();
    for (j = n = 0, seed = rand(); j < iterations; j++, seed += 13)
	    n += pBitCntFunc[i](seed);
    timeduration_t elapsed = time_since(start_time);
    stop = seconds_now();
    ct = (stop - start);
    if (ct < cmin) {
	    cmin = ct;
	    cminix = i;
    }
    if (ct > cmax) {
	    cmax = ct;
	    cmaxix = i;
    }
    print_elapsed_time(stdout, "bitcnts\0", (double)elapsed);
    printf("start: %f, stop: %f\n", start, stop);
    printf("%-38s> Time: %7.3f sec.; Bits: %ld\n", text[i], ct, n);
  }
  printf("\nBest  > %s\n", text[cminix]);
  printf("Worst > %s\n", text[cmaxix]);
  return 0;
}

static int CDECL bit_shifter(long int x)
{
  int i, n;
  
  for (i = n = 0; x && (i < (sizeof(long) * CHAR_BIT)); ++i, x >>= 1)
    n += (int)(x & 1L);
  return n;
}