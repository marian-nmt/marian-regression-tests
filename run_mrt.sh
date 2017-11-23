#!/bin/bash

SHELL=/bin/bash

export EXIT_CODE_SUCCESS=0
export EXIT_CODE_SKIP=100

export MRT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export MRT_TOOLS=$MRT_ROOT/tools
export MRT_MARIAN=${MARIAN:-$MRT_TOOLS/marian}
export MRT_MODELS=$MRT_ROOT/models
export MRT_DATA=$MRT_ROOT/data

# Check if Marian is compiled with CUDNN
export MRT_MARIAN_USE_CUDNN=$(cmake -L 2> /dev/null | grep -q -P "USE_CUDNN:BOOL=(ON|1)")

# Number of available devices
export MRT_NUM_DEVICES=${NUM_DEVICES:-1}


prefix=tests
if [ $# -ge 1 ]; then
    prefix="$1"
fi


function log {
    echo [$(date "+%m/%d/%Y %T")] $@
}

function logn {
    echo -n [$(date "+%m/%d/%Y %T")] $@
}

function format_time {
    dt=$(echo "$2 - $1" | bc)
    dh=$(echo "$dt/3600" | bc)
    dt2=$(echo "$dt-3600*$dh" | bc)
    dm=$(echo "$dt2/60" | bc)
    ds=$(echo "$dt2-60*$dm" | bc)
    LANG=C printf "%02d:%02d:%02.3fs" $dh $dm $ds
}

log "Using Marian: $MRT_MARIAN"
log "Using number of devices: $MRT_NUM_DEVICES"
log "Using CUDA visible devices: $CUDA_VISIBLE_DEVICES"

success=true
count_passed=0
count_skipped=0
count_failed=0
count_all=0

time_start=$(date +%s.%N)

# Traverse test directories
cd $MRT_ROOT
for test_dir in $(find $prefix -type d | grep -v "/_")
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
            echo " skipped"
            cd $MRT_ROOT
            continue;
        fi

        # Run test
        $SHELL -x $test_file > $test_name.stdout 2> $test_name.stderr
        exit_code=$?

        # Check exit code
        if [ $exit_code -eq $EXIT_CODE_SUCCESS ]; then
            ((++count_passed))
            rm $test_name.stdout $test_name.stderr
            echo " OK"
        elif [ $exit_code -eq $EXIT_CODE_SKIP ]; then
            ((++count_skipped))
            echo " skipped"
        else
            ((++count_failed))
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

echo "---------------------"
echo "Ran $count_all tests in $time_total, $count_passed passed, $count_skipped skipped, $count_failed failed"

# Exit code
$success && [ $count_all -gt 0 ]
