#!/bin/bash -x

#####################################################################
# SUMMARY: A template initialization script for a group of test scripts
# AUTHOR: <your-github-username>
#####################################################################

# Exit on error
set -e

# Test code goes here
test -f $MRT_MODELS/wmt16_systems/en-de/model.npz || exit 1
test -f $MRT_MODELS/wmt16_systems/marian.en-de.yml || exit 1

# Exit with success code
exit 0
