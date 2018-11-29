#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml \
  -t $(pwd)/text.src.in $(pwd)/text.trg.in --alignment --mini-batch 1 \
  | sed 's/^.* ||| //' > align.b1.out

# Compare scores
$MRT_TOOLS/diff.sh align.b1.out align.expected > align.b1.diff

# Exit with success code
exit 0
