#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml \
    --n-best -t text.src.in text.nbest.in \
    > nbest.out

$MRT_TOOLS/diff-nums.py nbest.out nbest.expected -p 0.0003 -o nbest.diff

# Exit with success code
exit 0
