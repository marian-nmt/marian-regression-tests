#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 16 -b 5 --alignment < text.in > align.out
$MRT_TOOLS/diff-floats.py -p 0.0001 $(pwd)/align.out $(pwd)/align.expected | tee $(pwd)/align.diff | head

# Exit with success code
exit 0
