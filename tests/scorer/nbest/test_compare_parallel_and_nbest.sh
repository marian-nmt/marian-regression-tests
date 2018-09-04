#!/bin/bash

# Exit on error
set -eo pipefail

test -e text.srcall.in || cat text.src.in | sed 'p;p;p;p' > text.srcall.in
test -e text.trg.in || cat text.nbest.in | sed 's/ ||| /\t/g' | cut -f2 > text.trg.in

# Run scorer
$MRT_MARIAN/build/marian-scorer \
    -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -m en-de/model.npz \
    -t $(pwd)/text.srcall.in $(pwd)/text.trg.in \
    > parallel.scores.out

$MRT_MARIAN/build/marian-scorer \
    -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -m en-de/model.npz \
    --n-best -t $(pwd)/text.src.in $(pwd)/text.nbest.in \
    > parallel.nbest.out

cat parallel.nbest.out | sed 's/ ||| /\t/g' | cut -f3 | tr ' ' '\t' | cut -f4 > parallel.nbest.scores.out

$MRT_TOOLS/diff-floats.py $(pwd)/parallel.scores.out $(pwd)/parallel.nbest.scores.out -p 0.0003 | tee $(pwd)/parallel.scores.diff | head

# Exit with success code
exit 0
