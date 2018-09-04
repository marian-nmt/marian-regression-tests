#!/bin/bash

# Exit on error
set -e

# Translate with s2s
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml \
  -b 12 --n-best < text.in > nbest.out

# Compare translations
cat nbest.out | sed 's/ ||| /\t/g' | cut -f2 > text.out
diff $(pwd)/text.out $(pwd)/text.expected | tee $(pwd)/text.diff | head

# Prepare source and target files for rescoring
cat text.in | perl -ne 'for$i(1..12){print}' > compare.src
cat nbest.out | sed 's/ ||| /\t/g' | cut -f2 > compare.trg

# Run rescorer
$MRT_MARIAN/build/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.yml \
  -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
  -t $(pwd)/compare.src $(pwd)/compare.trg > compare.scorer.out

# Compare scores
cat nbest.out | sed 's/ ||| /\t/g' | cut -f4 > compare.decoder.out
$MRT_TOOLS/diff-floats.py $(pwd)/compare.scorer.out $(pwd)/compare.decoder.out -p 0.0003 | tee $(pwd)/compare.diff | head

# Exit with success code
exit 0
