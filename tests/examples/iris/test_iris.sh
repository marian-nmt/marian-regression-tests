#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/build/iris_example > iris.out
$MRT_TOOLS/diff-nums.py iris.out iris.expected > iris.diff

# Exit with success code
exit 0
