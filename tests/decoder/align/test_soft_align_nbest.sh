#!/bin/bash

# Exit on error
set -e

# Test code goes here
rm -f soft.nbest.out soft.nbest.raw.out
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 5 -b 3 --n-best --alignment soft < text.in > soft.nbest.out
$MRT_TOOLS/diff-floats.py -s , -p 0.0001 $(pwd)/soft.nbest.out $(pwd)/soft.nbest.expected | tee $(pwd)/soft.nbest.diff | head

# Exit with success code
exit 0
