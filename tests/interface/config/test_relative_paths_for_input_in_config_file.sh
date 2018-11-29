#!/bin/bash

# Exit on error
set -e

rm -f relpaths_input.log
mkdir -p subdir

# Test code goes here
echo "this is a test" > relpaths_input.in

$MRT_MARIAN/marian-decoder -c ./subdir/relpaths_input.yml -o relpaths_input.out --log relpaths_input.log

test -e relpaths_input.log
test -e relpaths_input.out

# Check if relative paths from config files have been expanded
if ! grep -q "\.\./\.\./" relpaths_input.log; then exit 0; else exit 1; fi
if ! grep -q "\./subdir/\.\." relpaths_input.log; then exit 0; else exit 1; fi

# Exit with success code
exit 0
