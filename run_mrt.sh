#!/bin/bash

# Marian regression test script. Invocation examples:
#  ./run_mrt.sh
#  ./run_mrt.sh tests/training/basics
#  ./run_mrt.sh tests/training/basics/test_valid_script.sh

# Environment variables:
#  - MARIAN - path to Marian root directory
#  - CUDA_VISIBLE_DEVICES - CUDA's variable specifying GPU devices
#  - NUM_DEVICES - maximum number of GPU devices to be used

SHELL=/bin/bash

export LC_ALL=C.UTF-8

export MRT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export MRT_TOOLS=$MRT_ROOT/tools
export MRT_MARIAN="$( realpath ${MARIAN:-$MRT_TOOLS/marian} )"
export MRT_MODELS=$MRT_ROOT/models
export MRT_DATA=$MRT_ROOT/data

# Check if Marian is compiled with CUDNN
export MRT_MARIAN_USE_CUDNN=$(cmake -L $MRT_MARIAN/build 2> /dev/null | grep -P "USE_CUDNN:BOOL=(ON|on|1)")
export MRT_MARIAN_USE_MKL=$(cmake -L $MRT_MARIAN/build 2> /dev/null | grep -P "MKL_ROOT" | grep -vP "MKL_ROOT.*NOTFOUND")

# Number of available devices
export MRT_NUM_DEVICES=${NUM_DEVICES:-1}

# Exit codes
export EXIT_CODE_SUCCESS=0
export EXIT_CODE_SKIP=100


prefix=tests
if [ $# -ge 1 ]; then
    prefix="$@"
fi


function log {
    echo [$(date "+%m/%d/%Y %T")] $@
}

function logn {
    echo -n [$(date "+%m/%d/%Y %T")] $@
}

function format_time {
    dt=$(echo "$2 - $1" | bc 2>/dev/null)
    dh=$(echo "$dt/3600" | bc 2>/dev/null)
    dt2=$(echo "$dt-3600*$dh" | bc 2>/dev/null)
    dm=$(echo "$dt2/60" | bc 2>/dev/null)
    ds=$(echo "$dt2-60*$dm" | bc 2>/dev/null)
    LANG=C printf "%02d:%02d:%02.3fs" $dh $dm $ds
}

log "Using Marian: $MRT_MARIAN"
log "Using CUDNN: $MRT_MARIAN_USE_CUDNN"
log "Using MKL: $MRT_MARIAN_USE_MKL"
log "Using number of devices: $MRT_NUM_DEVICES"
log "Using CUDA visible devices: $CUDA_VISIBLE_DEVICES"

success=true
count_passed=0
count_skipped=0
count_failed=0
count_all=0

declare -a tests_skipped
declare -a tests_failed

test_dirs=$(find $prefix -type d | grep -v "/_")

if grep -q "/test_.*\.sh\$" <<< "$prefix"; then
    test_one_file=$(basename $prefix)
    test_dirs=$(dirname $prefix)
fi


time_start=$(date +%s.%N)

# Traverse test directories
cd $MRT_ROOT
for test_dir in $test_dirs
do
    log "Checking directory: $test_dir"
    nosetup=false

    # Run setup script if exists
    if [ -e $test_dir/setup.sh ]; then
        log "Running setup script"

        cd $test_dir
        $SHELL setup.sh &> setup.log
        if [ $? -ne 0 ]; then
            log "Warning: setup script returns a non-success exit code"
            success=false
            nosetup=true
        else
            rm setup.log
        fi
        cd $MRT_ROOT
    fi

    # Run tests
    for test_path in $(ls -A $test_dir/test_*.sh 2>/dev/null)
    do
        if [[ -n "$test_one_file" && $test_path != *"$test_one_file"* ]]; then
            continue
        fi
        test_time_start=$(date +%s.%N)
        ((++count_all))

        # Tests are executed from their directory
        cd $test_dir
        test_file=$(basename $test_path)
        test_name="${test_file%.*}"

        # Skip tests if setup failed
        logn "Running $test_path ... "
        if [ "$nosetup" = true ]; then
            ((++count_skipped))
            tests_skipped+=($test_path)
            echo " skipped"
            cd $MRT_ROOT
            continue;
        fi

        # Run test
        test_stdout=$test_name.stdout
        test_stderr=$test_name.stderr
        $SHELL -x $test_file > $test_stdout 2> $test_stderr
        exit_code=$?

        # Check exit code
        if [ $exit_code -eq $EXIT_CODE_SUCCESS ]; then
            ((++count_passed))
            echo " OK"
        elif [ $exit_code -eq $EXIT_CODE_SKIP ]; then
            ((++count_skipped))
            tests_skipped+=($test_path)
            echo " skipped"
        else
            ((++count_failed))
            tests_failed+=($test_path)
            echo " failed"
            success=false
        fi

        # Report time
        test_time_end=$(date +%s.%N)
        test_time=$(format_time $test_time_start $test_time_end)
        log "Test took $test_time"

        cd $MRT_ROOT
    done
    cd $MRT_ROOT

    # Run teardown script if exists
    if [ -e $test_dir/teardown.sh ]; then
        log "Running teardown script"

        cd $test_dir
        $SHELL teardown.sh &> teardown.log
        if [ $? -ne 0 ]; then
            log "Warning: teardown script returns a non-success exit code"
            success=false
        else
            rm teardown.log
        fi
        cd $MRT_ROOT
    fi
done

time_end=$(date +%s.%N)
time_total=$(format_time $time_start $time_end)

# Print skipped and failed tests
if [ -n "$tests_skipped" ] || [ -n "$tests_failed" ]; then
    echo "---------------------"
fi
[[ -z "$tests_skipped" ]] || echo "Skipped:"
for test_name in "${tests_skipped[@]}"; do
    echo "  - $test_name"
done
[[ -z "$tests_failed" ]] || echo "Failed:"
for test_name in "${tests_failed[@]}"; do
    echo "  - $test_name"
done
[[ -z "$tests_failed" ]] || echo "Logs:"
for test_name in "${tests_failed[@]}"; do
    echo "  - $(realpath $test_name | sed 's/.sh/.stderr/')"
done

# Print summary
echo "---------------------"
echo "Ran $count_all tests in $time_total, $count_passed passed, $count_skipped skipped, $count_failed failed"

# Return exit code
$success && [ $count_all -gt 0 ]
