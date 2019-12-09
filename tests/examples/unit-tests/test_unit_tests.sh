#!/bin/bash

# Exit on error
set -e

# Test code goes here
cd $MRT_MARIAN
env CTEST_OUTPUT_ON_FAILURE=1 ctest --force-new-ctest-process

# Exit with success code
exit 0
