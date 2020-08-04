#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml \
  -t $(pwd)/scores.src.in $(pwd)/scores.trg.in --normalize > nrm_scores.out

# Compare scores
$MRT_TOOLS/diff-nums.py nrm_scores.out nrm_scores.expected -p 0.0003 -o nrm_scores.diff

# Exit with success code
exit 0
