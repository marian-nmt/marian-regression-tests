#!/bin/bash

# Exit on error
set -eo pipefail

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt17_systems/marian.en-de.yml \
  -b 5 --n-best --normalize < text.in | tail -n +6 > nbest.out

# Compare n-best lists
$MRT_TOOLS/diff-floats.py -p 0.0002 $(pwd)/nbest.out $(pwd)/nbest.expected | tee $(pwd)/nbest.diff | head

# Compare with nematus scores
cat nbest.out | sed -r 's/ \|\|\| /\t/g' | cut -f4 | cut -c2- > nbest.scores.out
$MRT_TOOLS/diff-floats.py -p 0.0002 $(pwd)/nbest.scores.out $(pwd)/nbest.scores.nematus | tee $(pwd)/nbest.scores.diff | head

# Exit with success code
exit 0
