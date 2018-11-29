#!/bin/bash

# Exit on error
set -e

rm -f relpaths.log

# Test code goes here
echo "this is a test" | $MRT_MARIAN/marian-decoder -c relpaths.yml --log relpaths.log

test -e relpaths.log
if ! grep -q "\.\." relpaths.log; then exit 0; else exit 1; fi

# Exit with success code
exit 0
