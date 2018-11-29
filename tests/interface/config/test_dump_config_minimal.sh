#!/bin/bash

# Exit on error
set -e

rm -f dump_minimal.{yml,out}

# Run with no config file
$MRT_MARIAN/marian --train-sets $MRT_DATA/europarl.de-en/corpus.bpe.{de,en} --vocabs vocab.de.yml vocab.en.yml \
    --type s2s --mini-batch 8 --dim-rnn 32 --dim-emb 16 --after-batches 2 --dump-config minimal > dump_minimal.yml

# Remove first line and paths to train sets and vocabs
cat dump_minimal.yml | tail -n +2 | grep -v '  - ' > dump_minimal.out

# Compare
diff dump_minimal.out dump_minimal.expected | tee dump_minimal.diff

# Exit with success code
exit 0
