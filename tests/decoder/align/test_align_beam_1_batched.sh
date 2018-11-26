#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 32 -b 1 --alignment < text.in > align.batched.out
$MRT_TOOLS/diff-nums.py -p 0.0001 align.batched.out align.batched.expected -o align.batched.diff

# Exit with success code
exit 0
