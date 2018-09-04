#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/build/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.yml \
  -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
  -t $(pwd)/scores.src.in $(pwd)/scores.trg.in > scores.out

# Compare scores
$MRT_TOOLS/diff-floats.py scores.out scores.expected -p 0.0003

# Exit with success code
exit 0
