#!/bin/bash

# Exit on error
set -e

rm -rf overwrite overwrite.log
mkdir -p overwrite

# Test
$MRT_MARIAN/marian -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -m overwrite/model.npz -v vocab.de.yml vocab.en.yml \
    --config overwrite.yml --type s2s --mini-batch 1 --after-batches 1 --no-shuffle \
    --log overwrite.log

test -e overwrite.log

grep -q "type: s2s" overwrite.log
grep -q "mini-batch: 1" overwrite.log
grep -q "dim-rnn: 32" overwrite.log
grep -q "dim-emb: 16" overwrite.log
grep -q "after-batches: 1" overwrite.log
grep -q "shuffle: none" overwrite.log


# Exit with success code
exit 0
