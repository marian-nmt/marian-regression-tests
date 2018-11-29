#!/bin/bash

# Exit on error
set -e

rm -f relpaths_nocmd.log
mkdir -p subdir

# Test code goes here
echo "this is a test" > relpaths_nocmd.in

$MRT_MARIAN/marian-decoder -c relpaths.yml -i ./subdir/../relpaths_nocmd.in -o ./subdir/../relpaths_nocmd.out --log relpaths_nocmd.log

test -e relpaths_nocmd.log
test -e relpaths_nocmd.out

# Check if relative paths from config files have been expanded
if ! grep -q "\.\./\.\./" relpaths_nocmd.log; then exit 0; else exit 1; fi
# Check if relative paths from command-line have been left untouched
grep -q "\./subdir/\.\." relpaths_nocmd.log

# Exit with success code
exit 0
