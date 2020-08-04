#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml \
    -t $(pwd)/text.in $(pwd)/text.b3.out --word-scores --mini-batch 1 > word_scores_b1.out

# Compare scores
$MRT_TOOLS/diff-nums.py word_scores_b1.out word_scores.expected -p 0.0003 -o word_scores_b1.diff

# Exit with success code
exit 0
