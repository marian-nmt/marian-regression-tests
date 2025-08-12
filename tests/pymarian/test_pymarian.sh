MARIAN_ROOT=${MARIAN_ROOT:-$(dirname $MRT_MARIAN)}
PYMARIAN_TESTS_DIR=$MARIAN_ROOT/src/python/tests/regression
test -d $PYMARIAN_TESTS_DIR || exit 1
python -m pytest $PYMARIAN_TESTS_DIR
