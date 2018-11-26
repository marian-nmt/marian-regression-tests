#!/bin/bash

# Exit on error
set -e

rm -f relpaths_subdir.log

# Test code goes here
echo "this is a test" | $MRT_MARIAN/marian-decoder -c relpaths_subdir.yml subdir/relpaths_subdir.yml --log relpaths_subdir.log

test -e relpaths_subdir.log

# Check if there is no relative paths
if ! grep -q "\.\./\.\." relpaths_subdir.log; then exit 0; else exit 1; fi

# Exit with success code
exit 0
