#!/bin/bash -x

# Exit on error
set -e

rm -rf npzsuffix
mkdir -p npzsuffix

# Test code goes here
$MRT_MARIAN/marian \
    -m ./npzsuffix/model \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v $MRT_MODELS/wmt16_systems/en-de/vocab.{en,de}.json \
    --no-shuffle --dim-emb 32 --dim-rnn 32 \
    --save-freq 3 --after-batches 5 \
    > npzsuffix.log 2>&1 || true

test -e npzsuffix.log
grep -q "Unknown model format.*\.npz" npzsuffix.log

# Exit with success code
exit 0
