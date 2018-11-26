#!/bin/bash

# Exit on error
set -e

# Skip if no CUDNN found
if [ ! $MRT_MARIAN_USE_CUDNN ]; then
    exit 100
fi

# Translate with s2s
$MRT_MARIAN/marian-decoder  \
  -c $MRT_MODELS/char-s2s/translate.yml \
  -b 12 \
  --n-best < text.in > nbest.out

# Compare translations
cat nbest.out sed 's/ ||| /\t/g' | cut -f2 > text.out

# Prepare source and target files for rescoring
cat text.in | perl -ne 'for$i(1..12){print}' > compare.char.src
cat nbest.out | sed 's/ ||| /\t/g' | cut -f2  > compare.char.trg

# Run rescorer
$MRT_MARIAN/marian-scorer  -c $MRT_MODELS/char-s2s/translate.yml \
  -m $MRT_MODELS/char-s2s/model.npz \
  --max-length 7000 \
  --workspace 256 \
  --mini-batch 32 \
  -t $(pwd)/compare.char.src $(pwd)/compare.char.trg > compare.char.scorer.out


# Compare scores
cat nbest.out | sed 's/ ||| /\t/g' | cut -f3 | cut -d ' ' -f 2 > compare.char.decoder.out
$MRT_TOOLS/diff-nums.py compare.char.scorer.out compare.char.decoder.out -p 0.0003 -d compare.char.diff

# Exit with success code
exit 0
