#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml --mini-batch 32 \
    -t $(pwd)/text.in $(pwd)/text.b3.out --word-scores --normalize > word_scores_nrm.out

# Compare sentence scores only
cut -f1 -d' ' word_scores_nrm.out > word_scores_nrm.sent.out
$MRT_TOOLS/diff-nums.py word_scores_nrm.sent.out word_scores_nrm.sent.expected -p 0.0003 -o word_scores_nrm.sent.diff

# Compare word scores
$MRT_TOOLS/diff-nums.py word_scores_nrm.out word_scores_nrm.expected -p 0.0003 -o word_scores_nrm.diff

# Exit with success code
exit 0
