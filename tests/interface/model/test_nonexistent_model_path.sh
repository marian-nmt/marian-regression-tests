#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/marian \
    -m /non/existent/path/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v $MRT_MODELS/wmt16_systems/en-de/vocab.{en,de}.json \
    --no-shuffle --after-batches 1 \
    > nonexistent.log 2>&1 || true

test -e nonexistent.log
grep -q "Model directory does not exist" nonexistent.log

# Exit with success code
exit 0
