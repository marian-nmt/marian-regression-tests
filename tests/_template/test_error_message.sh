#!/bin/bash -x

#####################################################################
# SUMMARY: A template script for testing error messages from Marian
# AUTHOR: <your-github-username>
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f error.log

# Test code goes here
$MRT_MARIAN/marian-decoder -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
    -i text.in > error.log 2>&1 || true

# Check error message
test -e error.log
grep -q "Translating, but vocabularies are not given" error.log

# Exit with success code
exit 0
