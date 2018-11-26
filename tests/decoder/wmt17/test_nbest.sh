#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt17_systems/marian.en-de.yml \
  -b 5 --n-best --normalize < text.in | tail -n +6 > nbest.out

# Compare n-best lists
$MRT_TOOLS/diff-nums.py -p 0.0002 nbest.out nbest.expected -o nbest.diff

# Compare with nematus scores
cat nbest.out | sed -r 's/ \|\|\| /\t/g' | cut -f4 | cut -c2- > nbest.scores.out
$MRT_TOOLS/diff-nums.py -p 0.0002 nbest.scores.out nbest.scores.nematus -o nbest.scores.diff

# Exit with success code
exit 0
