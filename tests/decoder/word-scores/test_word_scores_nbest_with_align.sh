#!/bin/bash

#####################################################################
# SUMMARY: Generate word-level scores and word alignment in an n-best list 
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -b 3 --n-best --word-scores --alignment -n 1.0 < text.in > nbest_align_nrm.out
$MRT_TOOLS/diff-nums.py -p 0.0001 nbest_align_nrm.out nbest_align_nrm.expected -o nbest_align_nrm.diff

# Exit with success code
exit 0
