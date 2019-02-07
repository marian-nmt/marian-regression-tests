#!/bin/bash
#
# SUMMARY: Test if a single value option from a config file can be converted to a vector 
# AUTHOR: romang

# Exit on error
set -e

rm -rf load_castup load_castup.log
mkdir -p load_castup

# Run marian
$MRT_MARIAN/marian --train-sets $MRT_DATA/europarl.de-en/corpus.bpe.{de,en} --model load_castup/model.npz --vocabs vocab.de.yml vocab.en.yml --no-shuffle \
    --config load_castup.yml --log load_castup.log

test -e load_castup/model.npz
test -e load_castup.log

grep -q "type: s2s" load_castup.log
grep -q "lr-decay-inv-sqrt:$" load_castup.log
grep -q " - 142536475869" load_castup.log

# Exit with success code
exit 0
