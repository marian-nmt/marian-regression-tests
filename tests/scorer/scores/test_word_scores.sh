#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml --mini-batch 32 \
    -t $(pwd)/text.in $(pwd)/text.b3.out --word-scores > word_scores.out

# Compare scores
$MRT_TOOLS/diff-nums.py word_scores.out word_scores.expected -p 0.0003 -o word_scores.diff

# Exit with success code
exit 0
