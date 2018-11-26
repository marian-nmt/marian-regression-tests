#!/bin/bash

# Exit on error
set -e

rm -f novocab_scorer.log

echo "this is a test ." > file.in
echo "das ist ein test ." > file.out

# Test code goes here
$MRT_MARIAN/marian-scorer -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
    --type amun --dim-emb 500 --dim-vocabs 85000 85000 \
    -t file.in file.out > novocab_scorer.log 2>&1 || true

test -e novocab_scorer.log
grep -q "Scoring, but vocabularies are not given" novocab_scorer.log

# Exit with success code
exit 0
