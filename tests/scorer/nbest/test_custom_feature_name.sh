#!/bin/bash

# Exit on error
set -eo pipefail

# Run scorer
$MRT_MARIAN/build/marian-scorer \
    -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -m en-de/model.npz \
    --n-best --n-best-feature FeatureName -t $(pwd)/text.src.in $(pwd)/text.nbest.in \
    > custom.out

grep -c 'FeatureName= ' custom.out

cat custom.out | sed 's/ ||| /\t/g' | cut -f3 | tr ' ' '\t' | cut -f4 > custom.scores.out
cat nbest.expected | sed 's/ ||| /\t/g' | cut -f3 | tr ' ' '\t' | cut -f4 > nbest.scores.out

$MRT_TOOLS/diff-floats.py $(pwd)/custom.scores.out $(pwd)/nbest.scores.out -p 0.0003 | tee $(pwd)/custom.scores.diff | head

# Exit with success code
exit 0
