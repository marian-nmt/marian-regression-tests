#!/bin/bash

# Exit on error
set -e

rm -rf dump_config.yml

# Run with no config file
$MRT_MARIAN/marian --train-sets $MRT_DATA/europarl.de-en/corpus.bpe.{de,en} --vocabs vocab.de.yml vocab.en.yml \
    --type s2s --mini-batch 8 --dim-rnn 32 --dim-emb 16 --after-batches 2 --dump-config > dump_config.yml

test -e dump_config.yml

grep -q "type: s2s" dump_config.yml
grep -q "mini-batch: 8" dump_config.yml
grep -q "dim-rnn: 32" dump_config.yml
grep -q "dim-emb: 16" dump_config.yml
grep -q "train-sets:" dump_config.yml
grep -q "  - .*corpus\.bpe\." dump_config.yml

# Exit with success code
exit 0
