#!/bin/bash

#####################################################################
# SUMMARY: Check word alignment generated from CPU-based decoding
# TAGS: cpu align amun
#####################################################################

# Exit on error
set -e

# Skip if no MKL found
if [ ! $MRT_MARIAN_USE_MKL ]; then
    exit 100
fi

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 16 -b 1 --alignment --cpu-threads 8 < text.in > cpu.out
$MRT_TOOLS/diff-nums.py -p 0.0001 cpu.out cpu.expected -o cpu.diff

# Exit with success code
exit 0
