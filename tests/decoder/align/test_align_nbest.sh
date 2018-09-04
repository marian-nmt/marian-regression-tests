#!/bin/bash

# Exit on error
set -eo pipefail

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 16 -b 3 --n-best --alignment < text.in > align_nbest.out
$MRT_TOOLS/diff-floats.py -p 0.0001 $(pwd)/align_nbest.out $(pwd)/align_nbest.expected | tee $(pwd)/align_nbest.diff | head

# Exit with success code
exit 0
