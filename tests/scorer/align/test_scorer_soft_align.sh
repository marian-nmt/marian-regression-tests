#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/build/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
  -t $(pwd)/text.src.in $(pwd)/text.trg.in --alignment soft --mini-batch 16 \
  | sed 's/^.* ||| //' > soft.out

# Compare scores
$MRT_TOOLS/diff-floats.py -s , soft.out soft.expected > soft.diff

# Exit with success code
exit 0
