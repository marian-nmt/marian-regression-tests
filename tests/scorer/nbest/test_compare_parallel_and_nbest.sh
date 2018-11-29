#!/bin/bash

# Exit on error
set -e

test -e text.srcall.in || cat text.src.in | sed 'p;p;p;p' > text.srcall.in
test -e text.trg.in || cat text.nbest.in | sed 's/ ||| /\t/g' | cut -f2 > text.trg.in

# Run scorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml \
    -t text.srcall.in text.trg.in \
    > parallel.scores.out

$MRT_MARIAN/marian-scorer -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml \
    --n-best -t text.src.in text.nbest.in \
    > parallel.nbest.out

cat parallel.nbest.out | sed 's/ ||| /\t/g' | cut -f3 | tr ' ' '\t' | cut -f4 > parallel.nbest.scores.out

$MRT_TOOLS/diff-nums.py parallel.scores.out parallel.nbest.scores.out -p 0.0003 -o parallel.scores.diff

# Exit with success code
exit 0
