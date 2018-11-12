#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/build/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml \
  -t $(pwd)/scores.src.in $(pwd)/scores.trg.in --summary perplexity > summary_perplexity.out

# Compare scores
$MRT_TOOLS/diff-floats.py summary_perplexity.out summary_perplexity.expected -p 0.0003

# Exit with success code
exit 0
