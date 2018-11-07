#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/build/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml \
  -t $(pwd)/text.src.in $(pwd)/text.trg.in --alignment --mini-batch 16 \
  | sed 's/^.* ||| //' > align.out

# Compare scores
diff align.out align.expected > align.diff

# Exit with success code
exit 0
