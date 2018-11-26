#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml \
  -t $(pwd)/text.src.in $(pwd)/text.trg.in --alignment soft --mini-batch 16 \
  | sed 's/^.* ||| //' > soft.out

# Compare scores
$MRT_TOOLS/diff-nums.py -s , soft.out soft.expected -o soft.diff

# Exit with success code
exit 0
