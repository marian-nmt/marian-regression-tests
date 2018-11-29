#!/bin/bash

# Exit on error
set -e

rm -f nomodel_1of2_decoder.log
echo "this is a test ." > file.in

# Test code goes here
$MRT_MARIAN/marian-decoder -m $MRT_MODELS/wmt16_systems/en-de/model.npz /non/existent/path/to/1/of/2/models.npz \
    --type amun --dim-emb 500 --dim-vocabs 85000 85000 \
    -v $MRT_MODELS/wmt16_systems/en-de/vocab.en.json $MRT_MODELS/wmt16_systems/en-de/vocab.de.json \
    -i file.in > nomodel_1of2_decoder.log 2>&1 || true

test -e nomodel_1of2_decoder.log
grep -q "Model.* does not exist" nomodel_1of2_decoder.log

# Exit with success code
exit 0
