#!/bin/bash

# Exit on error
set -e

# Translate with s2s
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml \
  -b 12 --n-best < text.in > nbest.out

# Compare translations
cat nbest.out | sed 's/ ||| /\t/g' | cut -f2 > text.out
$MRT_TOOLS/diff.sh text.out text.expected > text.diff

# Prepare source and target files for rescoring
cat text.in | perl -ne 'for$i(1..12){print}' > compare.src
cat nbest.out | sed 's/ ||| /\t/g' | cut -f2 > compare.trg

# Run rescorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml \
  -t $(pwd)/compare.src $(pwd)/compare.trg > compare.scorer.out

# Compare scores
cat nbest.out | sed 's/ ||| /\t/g' | cut -f4 > compare.decoder.out
$MRT_TOOLS/diff-nums.py compare.scorer.out compare.decoder.out -p 0.0003 -o compare.scorer.diff

# Exit with success code
exit 0
