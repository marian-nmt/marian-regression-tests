#!/bin/bash

# Marian regression test script. Invocation examples:
#  ./run_mrt.sh
#  ./run_mrt.sh tests/training/basics
#  ./run_mrt.sh tests/training/basics/test_valid_script.sh
#  ./run_mrt.sh previous.log
#  ./run_mrt.sh '#tag'
# where previous.log contains a list of test files in separate lines.

# Environment variables:
#  - MARIAN - path to Marian build directory
#  - CUDA_VISIBLE_DEVICES - CUDA's variable specifying GPU device IDs
#  - NUM_DEVICES - maximum number of GPU devices to be used
#  - TIMEOUT - maximum duration for execution of a single test in the format
#    accepted by the timeout command; set to 0 to disable

SHELL=/bin/bash

export LC_ALL=C.UTF-8

function log {
    echo [$(date "+%m/%d/%Y %T")] $@
}

function logn {
    echo -n [$(date "+%m/%d/%Y %T")] $@
}

log "Running on $(hostname) as process $$"

export MRT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export MRT_TOOLS=$MRT_ROOT/tools
export MRT_MARIAN="$( realpath ${MARIAN:-$MRT_ROOT/../build} )"
export MRT_MODELS=$MRT_ROOT/models
export MRT_DATA=$MRT_ROOT/data

# Try adding build/ to MARIAN for backward compatibility
if [[ ! -e $MRT_MARIAN/marian-decoder ]]; then
    MRT_MARIAN="$MRT_MARIAN/build"
fi

# Check if required tools are present in marian directory
for cmd in marian marian-decoder marian-scorer marian-vocab; do
    if [ ! -e $MRT_MARIAN/$cmd ]; then
        echo "Error: '$MRT_MARIAN/$cmd' not found. Do you need to compile the toolkit first?"
        exit 1
    fi
done

log "Using Marian binary: $MRT_MARIAN/marian"

# Log Marian version
export MRT_MARIAN_VERSION=$($MRT_MARIAN/marian --version 2>&1)
log "Version: $MRT_MARIAN_VERSION"

# Get CMake settings from the --build-info option
if ! grep -q "build-info" < <( $MRT_MARIAN/marian --help ); then
    echo "Error: Marian is too old as it does not have the required --build-info option"
    exit 1
fi

$MRT_MARIAN/marian --build-info all 2> $MRT_ROOT/cmake.log

# Check Marian compilation settings
export MRT_MARIAN_BUILD_TYPE=$(cat $MRT_ROOT/cmake.log        | grep "CMAKE_BUILD_TYPE=" | cut -f2 -d=)
export MRT_MARIAN_COMPILER=$(cat $MRT_ROOT/cmake.log          | grep "CMAKE_CXX_COMPILER=" | cut -f2 -d=)
export MRT_MARIAN_USE_MKL=$(cat $MRT_ROOT/cmake.log           | egrep "COMPILE_CPU=(ON|on|1)")
export MRT_MARIAN_USE_CUDA=$(cat $MRT_ROOT/cmake.log          | egrep "COMPILE_CUDA=(ON|on|1)")
export MRT_MARIAN_USE_CUDNN=$(cat $MRT_ROOT/cmake.log         | egrep "USE_CUDNN=(ON|on|1)")
export MRT_MARIAN_USE_SENTENCEPIECE=$(cat $MRT_ROOT/cmake.log | egrep "USE_SENTENCEPIECE=(ON|on|1)")
export MRT_MARIAN_USE_FBGEMM=$(cat $MRT_ROOT/cmake.log        | egrep "USE_FBGEMM=(ON|on|1)")
export MRT_MARIAN_USE_UNITTESTS=$(cat $MRT_ROOT/cmake.log     | egrep "COMPILE_TESTS=(ON|on|1)")

log "Build type: $MRT_MARIAN_BUILD_TYPE"
log "Using compiler: $MRT_MARIAN_COMPILER"
log "Using MKL: $MRT_MARIAN_USE_MKL"
log "Using CUDNN: $MRT_MARIAN_USE_CUDNN"
log "Using SentencePiece: $MRT_MARIAN_USE_SENTENCEPIECE"
log "Using FBGEMM: $MRT_MARIAN_USE_FBGEMM"
log "Unit tests: $MRT_MARIAN_USE_UNITTESTS"

# Number of available devices
cuda_num_devices=$(($(echo $CUDA_VISIBLE_DEVICES | grep -c ',')+1))
export MRT_NUM_DEVICES=${NUM_DEVICES:-$cuda_num_devices}

log "Using CUDA visible devices: $CUDA_VISIBLE_DEVICES"
log "Using number of GPU devices: $MRT_NUM_DEVICES"

export MRT_TIMEOUT=${TIMEOUT:-5m}   # the default time out is 5 minutes, see `man timeout`
cmd_timeout=""
if [ $MRT_TIMEOUT != "0" ]; then
    cmd_timeout="timeout $MRT_TIMEOUT"
fi

log "Using time out: $MRT_TIMEOUT"

# Exit codes
export EXIT_CODE_SUCCESS=0
export EXIT_CODE_SKIP=100
export EXIT_CODE_TIMEOUT=124    # Exit code returned by the timeout command if timed out

function format_time {
    dt=$(echo "$2 - $1" | bc 2>/dev/null)
    dh=$(echo "$dt/3600" | bc 2>/dev/null)
    dt2=$(echo "$dt-3600*$dh" | bc 2>/dev/null)
    dm=$(echo "$dt2/60" | bc 2>/dev/null)
    ds=$(echo "$dt2-60*$dm" | bc 2>/dev/null)
    LANG=C printf "%02d:%02d:%02.3fs" $dh $dm $ds
}

###############################################################################
# Default directory with all regression tests
test_prefixes=tests

if [ $# -ge 1 ]; then
    test_prefixes=
    for arg in "$@"; do
        # A log file with paths to test files
        if [[ "$arg" = *.log ]]; then
            # Extract tests from .log file
            args=$(cat $arg | grep '/test_.*\.sh' | grep -v '/_' | sed 's/^ *- *//' | tr '\n' ' ' | sed 's/ *$//')
            test_prefixes="$test_prefixes $args"
        # A hash tag
        elif [[ "$arg" = '#'* ]]; then
            # Find all tests with the given hash tag
            tag=${arg:1}
            args=$(find tests -name '*test_*.sh' | xargs -I{} grep -H "^ *# *TAGS:.* $tag" {} | cut -f1 -d:)
            test_prefixes="$test_prefixes $args"
        # A test file or directory name
        else
            test_prefixes="$test_prefixes $arg"
        fi
    done
fi

# Extract all subdirectories, which will be traversed to look for regression tests
test_dirs=$(find $test_prefixes -type d | grep -v "/_")

if grep -q "/test_.*\.sh" <<< "$test_prefixes"; then
    test_files=$(printf '%s\n' $test_prefixes | sed 's!*/!!')
    test_dirs=$(printf '%s\n' $test_prefixes | xargs -I{} dirname {} | grep -v "/_" | sort | uniq)
fi


###############################################################################
success=true
count_all=0
count_failed=0
count_passed=0
count_skipped=0
count_timedout=0

declare -a tests_failed
declare -a tests_skipped
declare -a tests_timedout

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
        $cmd_timeout $SHELL -v setup.sh &> setup.log
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
        test_file=$(basename $test_path)
        test_name="${test_file%.*}"

        # In non-traverse mode skip tests if not requested
        if [[ -n "$test_files" && $test_files != *"$test_file"* ]]; then
            continue
        fi
        test_time_start=$(date +%s.%N)
        ((++count_all))

        # Tests are executed from their directory
        cd $test_dir

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
        # Note: all output gets written to stderr (very very few cases write to stdout)
        $cmd_timeout $SHELL -x $test_file 2> $test_file.log 1>&2
        exit_code=$?

        # Check exit code
        if [ $exit_code -eq $EXIT_CODE_SUCCESS ]; then
            ((++count_passed))
            echo " OK"
        elif [ $exit_code -eq $EXIT_CODE_SKIP ]; then
            ((++count_skipped))
            tests_skipped+=($test_path)
            echo " skipped"
        elif [ $exit_code -eq $EXIT_CODE_TIMEOUT ]; then
            ((++count_timedout))
            tests_timedout+=($test_path)
            # Add a comment to the test log file that it timed out
            echo "The test timed out after $TIMEOUT" >> $test_file.log
            # A timed out test is a failed test
            ((++count_failed))
            echo " timed out"
            success=false
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
        $cmd_timeout $SHELL teardown.sh &> teardown.log
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

prev_log=previous.log
rm -f $prev_log


###############################################################################
# Print skipped and failed tests
if [ -n "$tests_skipped" ] || [ -n "$tests_failed" ] || [ -n "$tests_timedout" ]; then
    echo "---------------------"
fi
[[ -z "$tests_skipped" ]] || echo "Skipped:" | tee -a $prev_log
for test_name in "${tests_skipped[@]}"; do
    echo "  - $test_name" | tee -a $prev_log
done
[[ -z "$tests_failed" ]] || echo "Failed:" | tee -a $prev_log
for test_name in "${tests_failed[@]}"; do
    echo "  - $test_name" | tee -a $prev_log
done
[[ -z "$tests_timedout" ]] || echo "Timed out:" | tee -a $prev_log
for test_name in "${tests_timedout[@]}"; do
    echo "  - $test_name" | tee -a $prev_log
done
[[ -z "$tests_failed" ]] || echo "Logs:"
for test_name in "${tests_failed[@]}"; do
    echo "  - $(realpath $test_name | sed 's/\.sh/.sh.log/')"
done


###############################################################################
# Print summary
echo "---------------------" | tee -a $prev_log
echo -n "Ran $count_all tests in $time_total, $count_passed passed, $count_skipped skipped, $count_failed failed" | tee -a $prev_log
[ -n "$tests_timedout" ] && (echo -n " (incl. $count_timedout timed out)" | tee -a $prev_log)
echo "" | tee -a $prev_log

# Return exit code
$success && [ $count_all -gt 0 ]
