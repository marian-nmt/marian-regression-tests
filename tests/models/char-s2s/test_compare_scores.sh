#!/bin/bash

# Exit on error
set -eo pipefail

# Skip if no CUDNN found
if [ ! $MRT_MARIAN_USE_CUDNN ]; then
    exit 100
fi

# Translate with s2s
$MRT_MARIAN/build/marian-decoder  \
  -c $MRT_MODELS/char-s2s/translate.yml \
  -b 12 \
  --n-best < text.in > nbest.out

# Compare translations
cat nbest.out sed 's/ ||| /\t/g' | cut -f2 > text.out

# Prepare source and target files for rescoring
cat text.in | perl -ne 'for$i(1..12){print}' > compare.src
cat nbest.out | sed 's/ ||| /\t/g' | cut -f2  > compare.trg

# Run rescorer
$MRT_MARIAN/build/marian-scorer  -c $MRT_MODELS/char-s2s/translate.yml \
  -m $MRT_MODELS/char-s2s/model.npz \
  --max-length 7000 \
  --workspace 256 \
  --mini-batch 32 \
  -t $(pwd)/compare.src $(pwd)/compare.trg > compare.scorer.out


# Compare scores
cat nbest.out | sed 's/ ||| /\t/g' | cut -f3 | cut -d ' ' -f 2 > compare.decoder.out
$MRT_TOOLS/diff-floats.py $(pwd)/compare.scorer.out $(pwd)/compare.decoder.out -p 0.0003 | tee $(pwd)/compare.diff | head

# Exit with success code
exit 0

