#!/bin/bash
#
# SUMMARY: Test if an alias in a config file does not override other options
# AUTHOR: romang

# Exit on error
set -e

rm -rf load_alias load_alias.log
mkdir -p load_alias

# Run Marian
$MRT_MARIAN/marian --train-sets $MRT_DATA/europarl.de-en/corpus.bpe.{de,en} --model load_alias/model.npz --vocabs vocab.de.yml vocab.en.yml --no-shuffle \
    --config load_alias.yml --log load_alias.log

test -e load_alias/model.npz
test -e load_alias.log

grep -q "type: transformer" load_alias.log
grep -q "learn-rate: 0.5" load_alias.log
grep -q "dim-emb: 16" load_alias.log

$MRT_TOOLS/diff.sh load_alias.out no_alias.out > load_alias.diff

# Exit with success code
exit 0
