#!/bin/bash

#####################################################################
# SUMMARY: Re-score sentences on CPU
# TAGS: cpu scorer
#####################################################################

# Exit on error
set -e

# Skip if no MKL found
if [ ! $MRT_MARIAN_USE_MKL ]; then
    exit 100
fi

# Run scorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml --cpu-threads 2 \
  -t $(pwd)/scores_cpu.src.in $(pwd)/scores_cpu.trg.in > scores_cpu.out

# Compare scores
$MRT_TOOLS/diff-nums.py scores_cpu.out scores_cpu.expected -p 0.0003 -o scores_cpu.diff

# Exit with success code
exit 0
