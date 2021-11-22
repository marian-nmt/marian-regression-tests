#!/bin/bash

#####################################################################
# SUMMARY: Abort if an alias does not support the option value
# AUTHOR: snukky
# TAGS: config
#####################################################################

# Exit on error
set -e

rm -rf alias_unk alias_unk.log
mkdir -p alias_unk

# Run with no config file
$MRT_MARIAN/marian --task some-unknown-alias-option transformer-base --dim-rnn 32 --dim-emb 16 --after-batches 2 \
    --train-sets $MRT_DATA/europarl.de-en/corpus.bpe.{de,en} --model alias_unk/model.npz --vocabs vocab.de.yml vocab.en.yml \
    > alias_unk.log 2>&1 || true

test -e alias_unk.log
grep -qi "unknown value.*some-unknown-alias-option.*for alias option" alias_unk.log

# Exit with success code
exit 0
