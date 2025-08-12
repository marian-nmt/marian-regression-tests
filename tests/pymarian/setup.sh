#!/usr/bin/env bash

which pymarian-eval >& /dev/null || {
    PYMARIAN_WHL=$(echo $MRT_MARIAN/pymarian-*.whl)
    echo "Installing pymarian from $PYMARIAN_WHL"
    if [[ -f $PYMARIAN_WHL ]]; then
        python -m pip install --upgrade pip
        python -m pip install $PYMARIAN_WHL
    else
        echo "No pymarian wheel found at $PYMARIAN_WHL" 1>&2
        exit 1
    fi
}

python -m pip install pytest

MARIAN_ROOT=${MARIAN_ROOT:-$(dirname $MRT_MARIAN)}
PYMARIAN_TESTS_DIR=$MARIAN_ROOT/src/python/tests/regression
test -d $PYMARIAN_TESTS_DIR || {
    echo "$PYMARIAN_TESTS_DIR not found" 1>&2
    exit 1
}
