#!/bin/bash

# Exit on error
set -e

rm -rf bestdeep_overwrite bestdeep_overwrite.log
mkdir -p bestdeep_overwrite


# Test
$MRT_MARIAN/marian -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -m bestdeep_overwrite/model.npz -v vocab.de.yml vocab.en.yml \
    --type s2s --dim-emb 32 --dim-rnn 16 --mini-batch 1 --after-batches 1 --no-shuffle \
   --best-deep --enc-depth 6 --dec-depth 6 --log bestdeep_overwrite.log

test -e bestdeep_overwrite.log

grep -q "layer-normalization: true" bestdeep_overwrite.log
grep -q "tied-embeddings: true" bestdeep_overwrite.log
grep -q "enc-depth: 6" bestdeep_overwrite.log
grep -q "dec-depth: 6" bestdeep_overwrite.log

grep -q "type: s2s" bestdeep_overwrite.log
grep -q "mini-batch: 1" bestdeep_overwrite.log


# Exit with success code
exit 0
