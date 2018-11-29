#!/bin/bash

# Exit on error
set -e

rm -f emptyvoc_decoder.log emptyvoc.yml
echo "this is a test ." > file.in
touch emptyvoc.yml

# Test code goes here
$MRT_MARIAN/marian-decoder -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
    --type amun --dim-emb 500 --dim-vocabs 85000 85000 -v emptyvoc.yml emptyvoc.yml \
    -i file.in > emptyvoc_decoder.log 2>&1 || true

test -e emptyvoc_decoder.log
grep -qi "empty vocabulary" emptyvoc_decoder.log

# Exit with success code
exit 0
