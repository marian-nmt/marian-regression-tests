#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf relative relative.log
mkdir -p relative

# Save a model with --relative-paths
$MRT_MARIAN/marian \
    --seed 2222 --no-shuffle --dim-emb 32 --dim-rnn 32 --optimizer sgd --mini-batch 1 --after-batches 1 \
    -m ../../training/basics/relative/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v ../basics/vocab.en.yml relative/../vocab.de.yml \
    --relative-paths true \
    --log relative.log

test -e relative/model.npz
test -e relative.log
test -e relative/model.npz.decoder.yml
test -e relative/model.npz.amun.yml

# Check if config files contain proper relative paths
grep -q "relative-paths: true" relative/model.npz.decoder.yml
grep -q " model\.npz" relative/model.npz.decoder.yml
grep -q " \.\./vocab\.en\.yml" relative/model.npz.decoder.yml
grep -q " \.\./vocab\.de\.yml" relative/model.npz.decoder.yml

grep -q "relative-paths: true" relative/model.npz.amun.yml
grep -q "path: model\.npz" relative/model.npz.amun.yml
grep -q "source-vocab: \.\./vocab\.en\.yml" relative/model.npz.amun.yml
grep -q "target-vocab: \.\./vocab\.de\.yml" relative/model.npz.amun.yml

# Exit with success code
exit 0
