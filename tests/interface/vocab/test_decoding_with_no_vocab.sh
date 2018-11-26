#!/bin/bash

# Exit on error
set -e

rm -f novocab_decoder.log
echo "this is a test ." > file.in

# Test code goes here
$MRT_MARIAN/marian-decoder -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
    --type amun --dim-emb 500 --dim-vocabs 85000 85000 \
    -i file.in > novocab_decoder.log 2>&1 || true

test -e novocab_decoder.log
grep -q "Translating, but vocabularies are not given" novocab_decoder.log

# Exit with success code
exit 0
