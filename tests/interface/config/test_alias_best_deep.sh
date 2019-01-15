#!/bin/bash

# Exit on error
set -e

rm -rf bestdeep bestdeep.log
mkdir -p bestdeep

# Test
$MRT_MARIAN/marian -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -m bestdeep/model.npz -v vocab.de.yml vocab.en.yml \
    --type s2s --dim-emb 32 --dim-rnn 16 --mini-batch 1 --after-batches 1 --no-shuffle \
   --best-deep --log bestdeep.log

test -e bestdeep.log

#grep -q "best-deep: true" bestdeep.log
grep -q "layer-normalization: true" bestdeep.log
grep -q "tied-embeddings: true" bestdeep.log
grep -q "enc-depth: 4" bestdeep.log
grep -q "dec-depth: 4" bestdeep.log

grep -q "type: s2s" bestdeep.log
grep -q "mini-batch: 1" bestdeep.log


# Exit with success code
exit 0
