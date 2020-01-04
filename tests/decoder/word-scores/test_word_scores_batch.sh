#!/bin/bash

#####################################################################
# SUMMARY: Generate word-level scores in batched translation
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 8 --maxi-batch 2 -b 5 --word-scores < text.in > batched.out
$MRT_TOOLS/diff-nums.py -p 0.0001 batched.out scores.expected -o batched.diff

# Exit with success code
exit 0
