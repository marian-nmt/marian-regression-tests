#!/bin/bash

# Exit on error
set -e

rm -f relative_paths.log

# Test code goes here
echo "this is a test" | $MRT_MARIAN/build/marian-decoder --relative-paths -c relative_paths.yml --log relative_paths.log

test -e relative_paths.log
if ! grep -q "\.\." relative_paths.log; then exit 0; else exit 1; fi

# Exit with success code
exit 0
