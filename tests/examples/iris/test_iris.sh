#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/build/iris_example > iris.out
$MRT_TOOLS/diff-floats.py $(pwd)/iris.out $(pwd)/iris.expected | tee $(pwd)/iris.diff | head

# Exit with success code
exit 0
