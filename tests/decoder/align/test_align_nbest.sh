#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 16 -b 3 --n-best --alignment < text.in > align_nbest.out
$MRT_TOOLS/diff-nums.py -p 0.0001 align_nbest.out align_nbest.expected -o align_nbest.diff

# Exit with success code
exit 0
