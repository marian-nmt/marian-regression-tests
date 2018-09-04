#!/bin/bash

# Exit on error
set -eo pipefail

# Run scorer
$MRT_MARIAN/build/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
  -t $(pwd)/text.src.in $(pwd)/text.trg.in --alignment --mini-batch 16 \
  | sed 's/^.* ||| //' > align.out

# Compare scores
diff $(pwd)/align.out $(pwd)/align.expected | tee $(pwd)/align.diff | head

# Exit with success code
exit 0
