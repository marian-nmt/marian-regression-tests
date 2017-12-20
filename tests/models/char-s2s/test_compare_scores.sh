#!/bin/bash

# Exit on error
set -e

# Translate with s2s
$MRT_RUN_MARIAN_DECODER \
  -c $MRT_MODELS/char-s2s/translate.yml \
  -b 12 \
  --n-best < text.in > nbest.out

# Compare translations
cat nbest.out sed 's/ ||| /\t/g' | cut -f2 > text.out

# Prepare source and target files for rescoring
cat text.in | perl -ne 'for$i(1..12){print}' > compare.src
cat nbest.out | sed 's/ ||| /\t/g' | cut -f2  > compare.trg

# Run rescorer
$MRT_RUN_MARIAN_SCORER -c $MRT_MODELS/char-s2s/translate.yml \
  -m $MRT_MODELS/char-s2s/model.npz \
  --max-length 7000 \
  --workspace 256 \
  --mini-batch 32 \
  -t $(pwd)/compare.src $(pwd)/compare.trg > compare.scorer.out


# Compare scores
cat nbest.out | sed 's/ ||| /\t/g' | cut -f3 | cut -d ' ' -f 2 > compare.decoder.out
$MRT_TOOLS/diff-floats.py compare.scorer.out compare.decoder.out -p 0.0003

# Exit with success code
exit 0

