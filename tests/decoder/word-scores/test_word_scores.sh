#!/bin/bash

#####################################################################
# SUMMARY: Generate word-level scores
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -b 5 --word-scores < text.in > scores.out
$MRT_TOOLS/diff-nums.py -p 0.0001 scores.out scores.expected -o scores.diff

# Exit with success code
exit 0
