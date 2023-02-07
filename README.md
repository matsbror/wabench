# WABench

A benchmark suite for standalone WebAssembly runtimes.

Note that WABench contains programs from existing benchmark suites and applications.

If you see any license/copyright issues, please let us know. We will remove the programs.


# Setting up for making benchmarks

Some pre-requisites

- Install clang. The `Makefile.in` assumes clang-15. Install also LLVM linker and some other tools needed
    - Example: `sudo apt install clang-15 lld-15 bc` on Ubuntu
- Install wasi sysroot
    - Example: Download from release here https://github.com/WebAssembly/wasi-sdk/releases/tag/wasi-sdk-19
    - Set environment variable WASI_SYSROOT to the location of the extracted directory.

You can compile each benchmark by running `make` in each benchmarks directory and run it natively and with the Webassembly runtimes defined in `common.sh` found in the top level directory.

