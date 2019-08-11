#!/bin/bash

#####################################################################
# SUMMARY: Test if an alias in a config file does not override other options
# AUTHOR: romang
# TAGS: future
#####################################################################

# Exit on error
set -e

rm -rf load_alias load_alias.log
mkdir -p load_alias

# Run Marian
$MRT_MARIAN/marian --no-shuffle --train-sets $MRT_DATA/europarl.de-en/corpus.bpe.{de,en} --model load_alias/model.npz \
    --vocabs vocab.deen.yml vocab.deen.yml --dim-vocabs 4000 4000 \
    --config load_alias.yml --log load_alias.log

test -e load_alias/model.npz
test -e load_alias.log

grep -q "type: transformer" load_alias.log
grep -q "learn-rate: 0.5" load_alias.log
grep -q "dim-emb: 16" load_alias.log

# Exit with success code
exit 0
