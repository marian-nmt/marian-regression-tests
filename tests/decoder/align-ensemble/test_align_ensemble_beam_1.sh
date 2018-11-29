#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.ensemble.yml --mini-batch 1 -b 1 --alignment < text.in > align.b1.out
$MRT_TOOLS/diff-nums.py -p 0.0001 align.b1.out align.b1.expected -o align.b1.diff

# Exit with success code
exit 0
