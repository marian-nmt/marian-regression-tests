#!/bin/bash

# Exit on error
set -eo pipefail

# Run scorer
$MRT_MARIAN/build/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.yml \
  -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
  -t $(pwd)/scores.src.in $(pwd)/scores.trg.in --summary perplexity > summary_perplexity.out

# Compare scores
$MRT_TOOLS/diff-floats.py $(pwd)/summary_perplexity.out $(pwd)/summary_perplexity.expected -p 0.0003 | tee $(pwd)/summary_perplexity.diff | head

# Exit with success code
exit 0
