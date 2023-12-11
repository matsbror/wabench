
# Check whether this run will be using an output file
Fileoutput=false
if [ "$1" == "-f" ]
then
   Fileoutput=true
   OutFile="$2"
   echo "Output results for each benchmark to file $OutFile in each benchmark directory"
fi

Wasm=$Native.wasm
WasmAOT=$Native.cwasm

Wasmtime="wasmtime"
Wasmer="wasmer"
WasmEdge="wasmedge"
WAMR="iwasm" 
wasm3=wasm3


export WABENCHMARK=`echo "$Prefix-${Native//.\/}"`
echoerr() { echo -e "$@" 1>&2; }

runaot() {
    cmd="$1"
    if [ "$2" = "-n" ] # dry run
    then 
        echo $1
        echo ""
        return 0
    fi
    start=`date +%s.%N`
    sh -c "$cmd" 1>&2
    end=`date +%s.%N`
    aottime=$( echo "$end - $start" | bc -l )
    echoerr "AOT compilation time: \t$aottime seconds"
}

# arg1 command
# arg2 output file
# arg3 native or runtime
# arg4 -f FILE or -n
runtest() {
    export WARUNTIME="$3"
    rm -f $2
    cmd="$1 >> $2 2>&1"
    if [ "$4" = "-n" ] # dry run
    then
        echo $cmd
        echo ""
        return 0
    fi
    if [ "$MeasureMem" = true ]
    then
        sh -c "/usr/bin/time -v $cmd"
        mem=$( cat "$2" | grep "Maximum resident set size (kbytes)" | sed 's/.*: //' )
        echo -e "$3:   \t$mem kbytes"
    elif [ "$MeasurePerf" = true ]
    then

        sh -c "perf stat $cmd"
        cycles=$( cat "$2" | grep "cycles" | sed 's/      cycles.*//' | sed 's/        //' )
        insns=$( cat "$2" | grep "instructions" | sed 's/      instructions.*//' | sed 's/        //')
        branches=$( cat "$2" | grep "branches" | grep -v "branch-misses" | sed 's/      branches.*//' | sed 's/        //')
        brmisses=$( cat "$2" | grep "branch-misses" | sed 's/      branch-misses.*//' | sed 's/        //')
        echo -e "$3:   \t$cycles cycles"
        echo -e "$3:   \t$insns instructions"
        echo -e "$3:   \t$branches branches"
        echo -e "$3:   \t$brmisses branch-misses"

        sh -c "perf stat -e cache-misses,cache-references $cmd"
        cachemisses=$( cat "$2" | grep "cache-misses" | sed 's/      cache-misses.*//' | sed 's/        //' )
        cacherefs=$( cat "$2" | grep "cache-references" | sed 's/      cache-references.*//' | sed 's/        //')
        echo -e "$3:   \t$cachemisses cache-misses"
        echo -e "$3:   \t$cacherefs cache-references"
    else
        start=`date +%s.%N`

        for (( i=1; i<=$Iter; i++ ))
        do
            # echo "do $cmd"

            echo "$HOSTTYPE, $3, $WABENCHMARK, calling, timestamp, $(($(date +%s%N)/1000))" >> $WABENCH_FILE

            if [ "$3" == "native" ] 
            then
                echo "$HOSTTYPE, native, $WABENCHMARK, starting, timestamp, $(($(date +%s%N)/1000))" >> $WABENCH_FILE
            fi

            sh -c "$cmd"
        done
        end=`date +%s.%N`
        runtime=$( echo "$end - $start" | bc -l )
        itertime=$( echo "scale=11; $runtime / $Iter" | bc -l )
        if [ "${itertime::1}" = "." ]
        then
            itertime="0${itertime}"
        fi
        echo -e "$3:   \t$itertime \t seconds"
        #echo "Total run time: $runtime seconds"
        #echo "Each iter time: $itertime seconds"
        #cat "$2"
    fi
    if grep -q "ERROR\|Error\|error\|Exception\|exception\|Fail\|fail" "$2"
    then
        echo "Error encountered. Please double-check"
    fi
}


echo "Iteration(s): $Iter"

######################################################################
### Native
######################################################################

if [ "$Fileoutput" = true ]
then
    export WABENCH_FILE=$OutFile
    export WARUNTIME="native"
    runtest "$Native $NativeArg" "output_native" "native" $1
    unset WABENCH_FILE
else
    export WABENCH_FILE=output_native
    runtest "$Native $NativeArg" "output_native" "native" $1
    unset WABENCH_FILE
fi

######################################################################
### wasmtime
######################################################################

if [ "$RunAOT" = true ]
then
     export WARUNTIME="wasmtime-aot"
    runaot "$Wasmtime compile $Wasm -o $WasmAOT" $1


    if [ "$Fileoutput" = true ]
    then
        export WABENCH_FILE=$OutFile
        runtest "$Wasmtime run --allow-precompiled --env 'WARUNTIME=$WARUNTIME' --env 'HOSTTYPE=$HOSTTYPE' --env 'WABENCHMARK=$WABENCHMARK' --env 'WABENCH_FILE=$OutFile' --dir=. $WasmAOT $NativeArg" "output_wasmtime" "wasmtime" $1
        unset WABENCH_FILE
    else
        export WABENCH_FILE=output_wasmtime
        runtest "$Wasmtime run --allow-precompiled --env 'WARUNTIME=$WARUNTIME' --env 'HOSTTYPE=$HOSTTYPE' --env 'WABENCHMARK=$WABENCHMARK' --dir=. $WasmAOT $NativeArg" "output_wasmtime" "wasmtime" $1
        unset WABENCH_FILE
    fi

else

    export WARUNTIME="wasmtime"

    if [ "$Fileoutput" = true ]
    then
        export WABENCH_FILE=$OutFile
        runtest "$Wasmtime run --env 'WARUNTIME=$WARUNTIME' --env 'HOSTTYPE=$HOSTTYPE' --env 'WABENCHMARK=$WABENCHMARK' --env 'WABENCH_FILE=$OutFile' --dir=. $Wasm $NativeArg" "output_wasmtime" "wasmtime" $1
        unset WABENCH_FILE
    else
        export WABENCH_FILE=output_wasmtime
        export WARUNTIME="wasmtime"
        runtest "$Wasmtime run --env 'WARUNTIME=$WARUNTIME' --env 'HOSTTYPE=$HOSTTYPE' --env 'WABENCHMARK=$WABENCHMARK' --dir=. $Wasm $NativeArg" "output_wasmtime" "wasmtime" $1
        unset WABENCH_FILE
    fi
fi



######################################################################
# #wasmer
######################################################################

# export WARUNTIME="wasmer"
# if [ "$RunAOT" = true ]
# then
#     export WARUNTIME="wasmer-aot"

#     runaot "$Wasmer compile $Wasm -o $WasmAOT" $1
#     runtest "$Wasmer run $WasmerDir $WasmAOT $WasmerNativeArg" "output_wasmer" "wasmer" $1
# else
# if [ "$Fileoutput" = true ]
# then
#     export WABENCH_FILE=$OutFile
#     runtest "$Wasmer run  --env WARUNTIME=$WARUNTIME --env HOSTTYPE=$HOSTTYPE --env WABENCHMARK=$WABENCHMARK --env WABENCH_FILE=$OutFile --dir=. $Wasm -- $NativeArg" "output_wasmer" "wasmer" $1
#     unset WABENCH_FILE
# else
#     export WABENCH_FILE=output_wasmer
#     runtest "$Wasmer run --env WARUNTIME=$WARUNTIME --env HOSTTYPE=$HOSTTYPE --env WABENCHMARK=$WABENCHMARK  --dir=. $Wasm -- $NativeArg" "output_wasmer" "wasmer" $1
#     unset WABENCH_FILE
# fi

# fi


######################################################################
#iwasm / wamr
######################################################################

if [ "$RunAOT" = true ]
then
    export WARUNTIME="iwasm-aot"
    if [ "$HOSTTYPE" = "Linux-aarch64" ]
    then
        runaot "wamrc --target=aarch64v8 -o $WasmAOT $Wasm"  $1
    else
        runaot "wamrc -o $WasmAOT $Wasm"  $1
    fi


    if [ "$Fileoutput" = true ]
    then
        export WABENCH_FILE=$OutFile
        runtest "$WAMR --stack-size=32768 --env='WARUNTIME=$WARUNTIME' --env='HOSTTYPE=$HOSTTYPE' --env='WABENCHMARK=$WABENCHMARK' --env='WABENCH_FILE=$OutFile' --dir=. $WasmAOT $NativeArg" "output_wamr" $WARUNTIME $1
        unset WABENCH_FILE

    else
        export WABENCH_FILE=output_wamr
        runtest "$WAMR  --stack-size=32768 --env='WARUNTIME=$WARUNTIME' --env='HOSTTYPE=$HOSTTYPE' --env='WABENCHMARK=$WABENCHMARK' --dir=. $WasmAOT $NativeArg" "output_wamr" $WARUNTIME $1
        unset WABENCH_FILE
    fi
    

else 

    if [ "$Fileoutput" = true ]
    then
        export WABENCH_FILE=$OutFile
        export WARUNTIME="iwasm-llvm-jit"
        runtest "$WAMR --llvm-jit --stack-size=32768 --env='WARUNTIME=$WARUNTIME' --env='HOSTTYPE=$HOSTTYPE' --env='WABENCHMARK=$WABENCHMARK' --env='WABENCH_FILE=$OutFile' --dir=. $Wasm $NativeArg" "output_wamr" $WARUNTIME $1
        # export WARUNTIME="iwasm-fast-jit"
        # runtest "$WAMR --fast-jit --stack-size=32768 --env='WARUNTIME=$WARUNTIME' --env='HOSTTYPE=$HOSTTYPE' --env='WABENCHMARK=$WABENCHMARK' --env='WABENCH_FILE=$OutFile' --dir=. $Wasm $NativeArg" "output_wamr" $WARUNTIME $1
        # export WARUNTIME="iwasm-multi-tier"
        # runtest "$WAMR --multi-tier-jit --stack-size=32768 --env='WARUNTIME=$WARUNTIME' --env='HOSTTYPE=$HOSTTYPE' --env='WABENCHMARK=$WABENCHMARK' --env='WABENCH_FILE=$OutFile' --dir=. $Wasm $NativeArg" "output_wamr" $WARUNTIME $1
        # export WARUNTIME="iwasm-interp"
        # runtest "$WAMR --interp --stack-size=32768 --env='WARUNTIME=$WARUNTIME' --env='HOSTTYPE=$HOSTTYPE' --env='WABENCHMARK=$WABENCHMARK' --env='WABENCH_FILE=$OutFile' --dir=. $Wasm $NativeArg" "output_wamr" $WARUNTIME $1

        unset WABENCH_FILE

    else
        export WABENCH_FILE=output_wamr
        export WARUNTIME="iwasm-llvm-jit"
        runtest "$WAMR --llvm-jit --stack-size=32768 --env='WARUNTIME=$WARUNTIME' --env='HOSTTYPE=$HOSTTYPE' --env='WABENCHMARK=$WABENCHMARK' --dir=. $Wasm $NativeArg" "output_wamr" $WARUNTIME $1
        # export WARUNTIME="iwasm-fast-jit"
        # runtest "$WAMR --fast-jit --stack-size=32768 --env='WARUNTIME=$WARUNTIME' --env='HOSTTYPE=$HOSTTYPE' --env='WABENCHMARK=$WABENCHMARK' --env='WABENCH_FILE=$OutFile' --dir=. $Wasm $NativeArg" "output_wamr" $WARUNTIME $1
        # export WARUNTIME="iwasm-multi-tier"
        # runtest "$WAMR --multi-tier-jit --stack-size=32768 --env='WARUNTIME=$WARUNTIME' --env='HOSTTYPE=$HOSTTYPE' --env='WABENCHMARK=$WABENCHMARK' --env='WABENCH_FILE=$OutFile' --dir=. $Wasm $NativeArg" "output_wamr" $WARUNTIME $1
        # export WARUNTIME="iwasm-interp"
        # runtest "$WAMR --interp --stack-size=32768 --env='WARUNTIME=$WARUNTIME' --env='HOSTTYPE=$HOSTTYPE' --env='WABENCHMARK=$WABENCHMARK' --dir=. $Wasm $NativeArg" "output_wamr" $WARUNTIME $1

        unset WABENCH_FILE
    fi
fi


######################################################################
# #wasmedge
######################################################################


# if [ "$RunAOT" = true ]
# then
# #runaot "wamrc -o $WasmAOT $Wasm"  $1
# #runtest "$WAMR --stack-size=32768 $WAMRDir $WasmAOT $WAMRNativeArg" "output_wasmer" "wamr" $1
# echo "wasmedge:"
# else
# if [ "$Fileoutput" = true ]
# then
#     export WABENCH_FILE=$OutFile
#     runtest "$WasmEdge --env WABENCHMARK=$WABENCHMARK --env WABENCH_FILE=$OutFile --dir=. $Wasm $NativeArg" "output_wasmedge" "wasmedge" $1
#     unset WABENCH_FILE
# else
#     export WABENCH_FILE=output_wasmedge
#     runtest "$WasmEdge --env WABENCHMARK=$WABENCHMARK --dir=. $Wasm $NativeArg" "output_wasmedge" "wasmedge" $1
#     unset WABENCH_FILE
# fi

# fi # RunAOT


if [ "$1" == "-n" ] # No need to compare results for a dry run
then
    return 0
fi

if [ "$CheckResult" = true ]
then
    echo "check results ..."
    diff output_native output_wasmtime
    diff output_native output_wasmer
    diff output_native output_wasmedge
    diff output_native output_wamr
fi
