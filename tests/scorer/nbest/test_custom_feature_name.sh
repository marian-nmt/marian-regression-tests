#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml \
    --n-best --n-best-feature FeatureName -t text.src.in text.nbest.in \
    > custom.out

grep -c 'FeatureName= ' custom.out

cat custom.out | sed 's/ ||| /\t/g' | cut -f3 | tr ' ' '\t' | cut -f4 > custom.scores.out
cat nbest.expected | sed 's/ ||| /\t/g' | cut -f3 | tr ' ' '\t' | cut -f4 > nbest.scores.out

$MRT_TOOLS/diff-nums.py custom.scores.out nbest.scores.out -p 0.0003 -o custom.scores.diff

# Exit with success code
exit 0
