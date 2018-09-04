#!/bin/bash

# Exit on error
set -eo pipefail

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 32 -b 1 --alignment < text.in > align.batched.out
$MRT_TOOLS/diff-floats.py -p 0.0001 $(pwd)/align.batched.out $(pwd)/align.batched.expected | tee $(pwd)/align.batched.diff | head

# Exit with success code
exit 0
