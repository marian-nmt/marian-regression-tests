#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml --mini-batch 32 \
    -t $(pwd)/text.in $(pwd)/text.b3.nbest.out --word-scores --n-best > word_scores_nbest.out

# Compare scores
$MRT_TOOLS/diff-nums.py word_scores_nbest.out word_scores_nbest.expected -p 0.0003 -o word_scores_nbest.diff

# Exit with success code
exit 0
