#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 16 -b 5 --alignment < text.in > align.out
$MRT_TOOLS/diff-nums.py -p 0.0001 align.out align.expected -o align.diff

# Exit with success code
exit 0
