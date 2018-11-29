#!/bin/bash

# Exit on error
set -e

rm -f nomodel_scorer.log
echo "this is a test ." > file.in
echo "das ist ein test ." > file.out

# Test code goes here
$MRT_MARIAN/marian-scorer -m  /non/existent/path/to/model.npz \
    --type amun --dim-emb 500 --dim-vocabs 85000 85000 \
    -v $MRT_MODELS/wmt16_systems/en-de/vocab.en.json $MRT_MODELS/wmt16_systems/en-de/vocab.de.json \
    -t file.in file.out > nomodel_scorer.log 2>&1 || true

test -e nomodel_scorer.log
grep -q "Model.* does not exist" nomodel_scorer.log

# Exit with success code
exit 0
