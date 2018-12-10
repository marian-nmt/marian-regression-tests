#!/bin/bash

# Exit on error
set -e

rm -rf nonex_config nonex_config.log
mkdir -p nonex_config

$MRT_MARIAN/marian --train-sets $MRT_DATA/europarl.de-en/corpus.bpe.{de,en} --model nonex_config/model.npz --vocabs vocab.de.yml vocab.en.yml \
    --config nonex_config.yml > nonex_config.log 2>&1 || true

test -e nonex_config.log
grep -q "option.* not expected.* blahblah" nonex_config.log

# Exit with success code
exit 0
