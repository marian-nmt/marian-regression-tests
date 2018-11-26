#!/bin/bash

# Exit on error
set -e

rm -rf booloff booloff.log
mkdir -p booloff

# Test
$MRT_MARIAN/marian -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -m booloff/model.npz -v vocab.de.yml vocab.en.yml \
    --dim-emb 32 --dim-rnn 16 --mini-batch 1 --after-batches 1 --no-shuffle \
    --config booloff.yml --layer-normalization false --log booloff.log

test -e booloff.log

grep -q "lr-report: true" booloff.log
grep -q "layer-normalization: false" booloff.log

# Exit with success code
exit 0
