#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/build/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
  -t $(pwd)/text.src.in $(pwd)/nbest.trg.in --alignment --mini-batch 16 --n-best > nbest.out

# Compare n-best lists
$MRT_TOOLS/diff-floats.py -p 0.0001 $(pwd)/nbest.out $(pwd)/nbest.expected | tee $(pwd)/nbest.diff | head

# Exit with success code
exit 0
