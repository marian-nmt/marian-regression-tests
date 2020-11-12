#!/bin/bash

#####################################################################
# SUMMARY: A classifier for Iris dataset
# TAGS: gcc5-fails
#####################################################################

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/iris_example > iris.out
$MRT_TOOLS/diff-nums.py iris.out iris.expected -o iris.diff

# Exit with success code
exit 0
