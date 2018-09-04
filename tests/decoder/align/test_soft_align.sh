#!/bin/bash

# Exit on error
set -e

# Test code goes here
rm -f soft.out soft.raw.out
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 5 -b 5 --alignment soft < text.in > soft.out
$MRT_TOOLS/diff-floats.py -s , -p 0.0001 $(pwd)/soft.out $(pwd)/soft.expected | tee $(pwd)/soft.diff | head

# Exit with success code
exit 0
