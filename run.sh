#!/bin/bash

RunAOT=false

MeasureMem=false

MeasurePerf=false

BenchRoot="$PWD"

CommonScript="$BenchRoot/common.sh"

BenchSize=5
BenchSuite=()
# Structure:  Benchmark directory                             Native           NativeArg         Iter  WasmDir
BenchSuite+=("calibrate"                                    "./calibrate"      ""                "100"    "") 
BenchSuite+=("JetStream2/gcc-loops"                         "./gcc-loops"      ""                "3"      "") 
BenchSuite+=("JetStream2/hashset"                           "./hashset"        ""                "15"     "") 
BenchSuite+=("JetStream2/quicksort"                         "./quicksort"      ""                "15"     "") 
BenchSuite+=("JetStream2/tsf"                               "./tsf"            "10000"           "3"     ".") 
BenchSuite+=("MiBench/automotive/basicmath"                 "./basicmath"      ""                "15"     "") 
BenchSuite+=("MiBench/automotive/bitcount"                  "./bitcount"       "1125000"         "15"     "")
BenchSuite+=("MiBench/consumer/jpeg/cjpeg"                  "./cjpeg"          "-dct int -progressive -opt -outfile output_large_encode.jpeg input_large.ppm" "15" ".")  
BenchSuite+=("MiBench/consumer/jpeg/djpeg"                  "./djpeg"          "-dct int -ppm -outfile output_large_decode.ppm input_large.jpg" "15" ".")
BenchSuite+=("MiBench/office/stringsearch"                  "./stringsearch"   ""          "30"  "")       
BenchSuite+=("MiBench/security/blowfish"                    "./blowfish"       "e input_large.asc output_large.enc 1234567890abcdeffedcba0987654321" "10"  ".")               
#BenchSuite+=("MiBench/security/blowfish"                    "./blowfish"       "d input_large.enc output_large.asc 1234567890abcdeffedcba0987654321" "10"  ".")
BenchSuite+=("MiBench/security/rijndael"                    "./rijndael"       "input_large.asc output_large.enc e 1234567890abcdeffedcba09876543211234567890abcdeffedcba0987654321" "15"  ".")   
# BenchSuite+=("MiBench/security/rijndael"                    "./rijndael"      "input_large.enc output_large.dec d 1234567890abcdeffedcba09876543211234567890abcdeffedcba0987654321" "10"  ".")
BenchSuite+=("MiBench/security/sha"                         "./sha"            "input_large.asc" "15"   ".") # 0.07
BenchSuite+=("MiBench/telecomm/adpcm/rawcaudio"             "./rawcaudio"      "< large.pcm"     "15"   ".") # 0.27
BenchSuite+=("MiBench/telecomm/adpcm/rawdaudio"             "./rawdaudio"      "< large.adpcm"   "15"   ".") # 0.23
BenchSuite+=("MiBench/telecomm/crc32"                       "./crc32"          "large.pcm"       "15"   ".") # 0.21 
BenchSuite+=("PolyBench/datamining/correlation"             "./correlation"    ""                "3"    "") # 12.4
BenchSuite+=("PolyBench/datamining/covariance"              "./covariance"     ""                "3"    "") # 14.4
BenchSuite+=("PolyBench/linear-algebra/blas/gemm"           "./gemm"           ""                "3"    "") # 7
BenchSuite+=("PolyBench/linear-algebra/blas/gemver"         "./gemver"         ""                "15"   "") # 0.1
BenchSuite+=("PolyBench/linear-algebra/blas/gesummv"        "./gesummv"        ""                "15"   "") # 0.07
BenchSuite+=("PolyBench/linear-algebra/blas/symm"           "./symm"           ""                "3"    "") # 10
BenchSuite+=("PolyBench/linear-algebra/blas/syr2k"          "./syr2k"          ""                "3"    "") # 10
BenchSuite+=("PolyBench/linear-algebra/blas/syrk"           "./syrk"           ""                "3"    "") # 8.3
BenchSuite+=("PolyBench/linear-algebra/blas/trmm"           "./trmm"           ""                "3"    "") # 10
BenchSuite+=("PolyBench/linear-algebra/kernels/2mm"         "./2mm"            ""                "3"    "") # 8
BenchSuite+=("PolyBench/linear-algebra/kernels/3mm"         "./3mm"            ""                "3"    "") # 9.5
BenchSuite+=("PolyBench/linear-algebra/kernels/atax"        "./atax"           ""                "15"    "") # 0.1
BenchSuite+=("PolyBench/linear-algebra/kernels/bicg"        "./bicg"           ""                "15"   "") # 0.1
BenchSuite+=("PolyBench/linear-algebra/kernels/doitgen"     "./doitgen"        ""                "1"   "") # 36
BenchSuite+=("PolyBench/linear-algebra/kernels/mvt"         "./mvt"            ""                "15"   "") # 0.12
BenchSuite+=("PolyBench/linear-algebra/solvers/cholesky"    "./cholesky"       ""                "1"   "") # 41
BenchSuite+=("PolyBench/linear-algebra/solvers/durbin"      "./durbin"         ""                "15"  "") # 0.06
BenchSuite+=("PolyBench/linear-algebra/solvers/gramschmidt" "./gramschmidt"    ""                "1"   "") # 26
BenchSuite+=("PolyBench/linear-algebra/solvers/lu"          "./lu"             ""                "1"   "") # 61
BenchSuite+=("PolyBench/linear-algebra/solvers/ludcmp"      "./ludcmp"         ""                "1"   "") # 38
BenchSuite+=("PolyBench/linear-algebra/solvers/trisolv"     "./trisolv"        ""                "15"  "") # 0.06
BenchSuite+=("PolyBench/medley/deriche"                     "./deriche"        ""                "1"   "") # 50.5
BenchSuite+=("PolyBench/medley/floyd-warshall"              "./floyd-warshall" ""                "1"   "") # 63
BenchSuite+=("PolyBench/medley/nussinov"                    "./nussinov"       ""                "1"   "") # 25
BenchSuite+=("PolyBench/stencils/adi"                       "./adi"            ""                "1"   "") # 16.4
BenchSuite+=("PolyBench/stencils/fdtd-2d"                   "./fdtd-2d"        ""                "1"   "") # 29
BenchSuite+=("PolyBench/stencils/heat-3d"                   "./heat-3d"        ""                "1"   "") # 17.9
BenchSuite+=("PolyBench/stencils/jacobi-1d"                 "./jacobi-1d"      ""                "15"  "") # 0.05
BenchSuite+=("PolyBench/stencils/jacobi-2d"                 "./jacobi-2d"      ""                "1"   "") # 12.7
BenchSuite+=("PolyBench/stencils/seidel-2d"                 "./seidel-2d"      ""                                        "1"   "")  # 41
BenchSuite+=("Whole_Applications/bzip2"                     "./bzip2"          "-k -f -z input_file"                     "15"   ".") # 0.22
BenchSuite+=("Whole_Applications/espeak"                    "./espeak"         "-f input.txt -s 120 -w output_file.wav"  "1"   ".") # 34
BenchSuite+=("Whole_Applications/facedetection"             "./facedetection"  "input.png"                               "15"   ".") # 0.64
BenchSuite+=("Whole_Applications/gnuchess"                  "./gnuchess"       "< input"                                 "3"   ".") # 3.6
BenchSuite+=("Whole_Applications/mnist"                     "./mnist"          ""                                        "1"   ".") # 135
BenchSuite+=("Whole_Applications/snappy"                    "./snappy"         ""                                        "3"   "") # 2
BenchSuite+=("Whole_Applications/whitedb"                   "./whitedb"        ""                                        "1"   "") # 16.6

NumBench=$( echo "scale=0; ${#BenchSuite[@]} / $BenchSize" | bc -l )

for (( idx=0; idx<${#BenchSuite[@]}; idx+=${BenchSize} ));
do
    nth=$( echo "scale=0; $idx / $BenchSize" | bc -l)
    nth=$((nth+1))

    echo "[${nth}/${NumBench}] ${BenchSuite[idx]}"

    # Enter benchmark directory
    cd ${BenchSuite[idx]}

    # Setup environment 
    Native=${BenchSuite[idx+1]}
    NativeArg=${BenchSuite[idx+2]}
    Iter=$( echo ${BenchSuite[idx+3]} | bc -l )
    WasmDir=${BenchSuite[idx+4]}

    # Check whether this is a dry run
    if [ "$1" != "-n" ]
    then
        # Check whether there exist binaries
        if [ ! -f "$Native" ]
        then
            echo "Building binaries..."
            make > /dev/null 2>&1
        fi
        if [ ! -f "$Native.wasm" ]
        then
            echo "Cannot build WebAssembly binary..."
            continue
        fi
    fi

    # Run benchmark
    echo "Running..."
    . $CommonScript

    # Clean up
    if [ "$1" != "-n" ]
    then
        echo "Cleanup..."
        make clean > /dev/null 2>&1
    fi

    # Enter the root directory
    cd "$BenchRoot"
    echo ""
done
