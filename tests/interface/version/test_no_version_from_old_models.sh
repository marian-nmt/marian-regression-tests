#!/bin/bash

# Exit on error
set -e

# Test code goes here
rm -rf noversion noversion.log
mkdir -p noversion

echo "test" | $MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml 2> noversion.log

test -e noversion.log
if grep -q "created with Marian" noversion.log; then
    exit 1
fi

# Exit with success code
exit 0
