#!/bin/bash

#####################################################################
# SUMMARY: Generate word-level scores in an n-best list
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -b 3 --n-best --word-scores < text.in > nbest.out
$MRT_TOOLS/diff-nums.py -p 0.0001 nbest.out nbest.expected -o nbest.diff

# Exit with success code
exit 0
