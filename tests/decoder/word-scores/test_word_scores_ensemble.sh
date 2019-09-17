#!/bin/bash

#####################################################################
# SUMMARY: Generate word-level scores with an ensemble system
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.ensemble.yml -b 3 --word-scores < text.in > ensemble.out
$MRT_TOOLS/diff-nums.py -p 0.0001 ensemble.out ensemble.expected -o ensemble.diff

# Exit with success code
exit 0
