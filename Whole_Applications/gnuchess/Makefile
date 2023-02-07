Benchmark = gnuchess

SRCDIR = ./src
SRCSUFFIX = c

CFLAGS =  -D_WASI_EMULATED_SIGNAL
CINCLUDE = -I./src
OPT = -O2
LDFLAGS = -lm
WASM_LDFLAGS =  -lwasi-emulated-signal

include ../../Makefile.in
