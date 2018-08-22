#!/bin/bash

# Exit on error
set -e

rm -rf load_config load_config.log no_config.log
mkdir -p load_config

# Run with no config file
$MRT_MARIAN/build/marian --train-sets $MRT_DATA/europarl.de-en/corpus.bpe.{de,en} --model load_config/model.npz --vocabs vocab.de.yml vocab.en.yml \
    --type s2s --mini-batch 8 --dim-rnn 32 --dim-emb 16 --after-batches 2 --log load_config.log

test -e load_config/model.npz
test -e load_config.log

# Clean working directory and log file
mv load_config.log no_config.log
rm -rf load_config
mkdir -p load_config

# Run with config file and the same options
$MRT_MARIAN/build/marian --train-sets $MRT_DATA/europarl.de-en/corpus.bpe.{de,en} --model load_config/model.npz --vocabs vocab.de.yml vocab.en.yml \
    --config load_config.yml --log load_config.log

test -e load_config/model.npz
test -e load_config.log

grep -q "type: s2s" load_config.log
grep -q "mini-batch: 8" load_config.log
grep -q "dim-rnn: 32" load_config.log
grep -q "dim-emb: 16" load_config.log

cat no_config.log | grep -v "\[memory\]" | $MRT_TOOLS/strip-timestamps.sh > no_config.out
cat load_config.log | grep -v "\[memory\]" | $MRT_TOOLS/strip-timestamps.sh > load_config.out

diff no_config.out load_config.out > load_config.diff

# Exit with success code
exit 0