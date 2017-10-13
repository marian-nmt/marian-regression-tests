#!/bin/bash

# Exit on error
set -e

# Translate with s2s
$MRT_MARIAN/build/s2s -c $MRT_MODELS/wmt16.en-de/marian.yml -b 12 --n-best < text.in > nbest.out

# Compare translations
cat nbest.out | sed 's/ ||| /\t/g' | cut -f2 > text.out
diff text.out text.expected > text.diff

# Prepare source and target files for rescoring
cat text.in | perl -ne 'for$i(1..12){print}' > rescorer.src
cat nbest.out | sed 's/ ||| /\t/g' | cut -f2 > rescorer.trg

# Run rescorer
$MRT_MARIAN/build/rescorer -c $MRT_MODELS/wmt16.en-de/marian.yml -t $(pwd)/rescorer.src $(pwd)/rescorer.trg > scores.rescorer

# Compare scores
cat nbest.out | sed 's/ ||| /\t/g' | cut -f4 > scores.decoder
$MRT_TOOLS/diff-floats.py scores.rescorer scores.decoder -p 0.0003

# Exit with success code
exit 0
