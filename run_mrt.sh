#!/bin/bash

SHELL=/bin/bash

export MRT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export MRT_TOOLS=$MRT_ROOT/tools
export MRT_MARIAN=$MRT_TOOLS/marian
export MRT_MODELS=$MRT_ROOT/models
export MRT_DATA=$MRT_ROOT/data

export MRT_GPUS=0
export MRT_GPU=0

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
    printf "%02d:%02d:%02.3fs" $dh $dm $ds
}

success=false
count_passed=0
count_failed=0
count_all=0

time_start=$(date +%s.%N)

# Traverse test directories
cd $MRT_ROOT
for test_dir in $(find $prefix -type d | grep -v "/_")
do
    log "Checking directory: $test_dir"
    success=true

    # Run setup script if exists
    if [ -e $test_dir/setup.sh ]; then
        log "Running setup script"

        cd $test_dir
        $SHELL setup.sh &> setup.log
        if [ $? -ne 0 ]; then
            log "Error: setup script returns a non-success exit code"
            success=false
            break
        else
            rm setup.log
        fi
        cd $MRT_ROOT
    fi

    # Don't run tests if setup failed
    test $success || continue

    # Run tests
    for test_path in $(ls -A $test_dir/test_*.sh 2>/dev/null)
    do
        test_time_start=$(date +%s.%N)
        ((++count_all))

        # Tests are executed from their directory
        cd $test_dir
        test_file=$(basename $test_path)
        test_name="${test_file%.*}"

        # Run test
        logn "Running $test_path ... "
        $SHELL $test_file > $test_name.stdout 2> $test_name.stderr

        # Check exit code
        if [ $? -eq 0 ]; then
            ((++count_passed))
            echo " OK"
            rm $test_name.stdout $test_name.stderr
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

    # Don't teardown if a test failed
    test $success || continue

    # Run teardown script if exists
    if [ -e $test_dir/teardown.sh ]; then
        log "Running teardown script"

        cd $test_dir
        $SHELL teardown.sh &> teardown.log
        if [ $? -ne 0 ]; then
            log "Error: teardown script returns a non-success exit code"
            success=false
            break
        else
            rm teardown.log
        fi
        cd $MRT_ROOT
    fi
done

time_end=$(date +%s.%N)
time_total=$(format_time $time_start $time_end)

echo "Ran $count_all tests in $time_total, $count_passed passed, $count_failed failed"

# Exit code
[ $success ] && [ $count_all -gt 0 ]
