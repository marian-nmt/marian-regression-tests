#!/bin/bash

#####################################################################
# SUMMARY: Generate length-normalized word-level scores
# TAGS: word-scores normalize
#####################################################################

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -b 5 --word-scores -n < text.in > scores_nrm.out

# Note: word-level scores are not normalized, only sentence-level scores in beam-search
$MRT_TOOLS/diff-nums.py -p 0.0001 scores_nrm.out scores_nrm.expected -o scores_nrm.diff

# Exit with success code
exit 0
