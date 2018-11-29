#!/bin/bash

# Exit on error
set -e

rm -rf vectoroff vectoroff.log
mkdir -p vectoroff

# Test
$MRT_MARIAN/marian -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -m vectoroff/model.npz -v vocab.de.yml vocab.en.yml \
    --dim-emb 32 --dim-rnn 16 --mini-batch 1 --after-batches 1 --no-shuffle \
    --valid-metrics [] --transformer-tied-layers [] --config vectoroff.yml --log vectoroff.log

test -e vectoroff.log

cat vectoroff.log | grep -A1 "valid-metrics" | grep -qP ".*\[\]"
cat vectoroff.log | grep -A1 "transformer-tied-layers" | grep -qP ".*\[\]"

# Exit with success code
exit 0
