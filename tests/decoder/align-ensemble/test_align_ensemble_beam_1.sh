#!/bin/bash

# Exit on error
set -eo pipefail

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.ensemble.yml --mini-batch 1 -b 1 --alignment < text.in > align.b1.out
$MRT_TOOLS/diff-floats.py -p 0.0001 $(pwd)/align.b1.out $(pwd)/align.b1.expected | tee $(pwd)/align.b1.diff | head

# Exit with success code
exit 0
