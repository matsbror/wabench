Wasm=$Native.wasm
WasmAOT=$Native.cwasm

Wasmtime="wasmtime"
Wasmer="$HOME/.wasmer/bin/wasmer"
Wasm3="wasm3"
WAMR="iwasm"

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

runtest() {
    cmd="$1 >$2 2>&1"
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

if [ ! -z "$WasmDir" ]
then
    WasmtimeDir="--dir $WasmDir"
    WasmerDir="--dir $WasmDir"
    WAMRDir="--dir=$WasmDir"
fi

if [ ! -z "$NativeArg" ]
then
    WasmtimeNativeArg="-- $NativeArg"
    WasmerNativeArg="-- $NativeArg"
    Wasm3NativeArg="$NativeArg"
    WAMRNativeArg="$NativeArg"
fi

#echo "Iteration(s): $Iter"

runtest "$Native $NativeArg" "output_native" "native" $1

if [ "$RunAOT" = true ]
then
runaot "$Wasmtime compile $Wasm -o $WasmAOT" $1
runtest "$Wasmtime run --allow-precompiled $WasmtimeDir $WasmAOT $WasmtimeNativeArg" "output_wasmtime" "wasmtime" $1
else
runtest "$Wasmtime run $WasmtimeDir $Wasm $WasmtimeNativeArg" "output_wasmtime" "wasmtime" $1
fi

if [ "$RunAOT" = true ]
then
runaot "$Wasmer compile $Wasm -o $WasmAOT" $1
runtest "$Wasmer run $WasmerDir $WasmAOT $WasmerNativeArg" "output_wasmer" "wasmer" $1
else
runtest "$Wasmer run $WasmerDir $Wasm $WasmerNativeArg" "output_wasmer" "wasmer" $1
fi

# runtest "$Wasmer --singlepass $WasmerDir $Wasm $WasmerNativeArg" "output_wasmer" "wasmer (sp)" $1

# runtest "$Wasmer --cranelift $WasmerDir $Wasm $WasmerNativeArg" "output_wasmer" "wasmer (cl)" $1

# runtest "$Wasmer --llvm $WasmerDir $Wasm $WasmerNativeArg" "output_wasmer" "wasmer (ll)" $1


if [ "$RunAOT" = true ]
then
runaot "wamrc -o $WasmAOT $Wasm"  $1
runtest "$WAMR --stack-size=32768 $WAMRDir $WasmAOT $WAMRNativeArg" "output_wasmer" "wamr" $1
else
# 32KB stack size for WAMR
runtest "$WAMR --stack-size=32768 $WAMRDir $Wasm $WAMRNativeArg" "output_wamr" "wamr" $1
fi

if [ "$RunAOT" = true ]
then
#runaot "wamrc -o $WasmAOT $Wasm"  $1
#runtest "$WAMR --stack-size=32768 $WAMRDir $WasmAOT $WAMRNativeArg" "output_wasmer" "wamr" $1
echo "wasm3:"
else
# enlarge stack size for wasm3
runtest "$Wasm3 --stack-size 1000000 $Wasm $Wasm3NativeArg" "output_wasm3" "wasm3" $1
fi


if [ "$1" == "-n" ] # No need to compare results for a dry run
then
    return 0
fi

if [ "$CheckResult" = true ]
then
    echo "check results ..."
    diff output_native output_wasmtime
    diff output_native output_wasmer
    diff output_native output_wasm3
    diff output_native output_wamr
fi
