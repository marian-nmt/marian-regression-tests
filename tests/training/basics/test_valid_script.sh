#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf valid valid.log valid_script.temp
mkdir -p valid

$MRT_MARIAN/build/marian \
    --seed 2222 --no-shuffle --dim-emb 128 --dim-rnn 256 \
    -m valid/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} \
    -v vocab.en.yml vocab.de.yml --dim-vocabs 50000 50000 \
    --disp-freq 10 --valid-freq 30 --after-batches 150 \
    --valid-metrics cross-entropy valid-script \
    --valid-script-path ./valid_script.sh \
    --valid-sets $MRT_DATA/europarl.de-en/toy.bpe.{en,de} \
    --valid-log valid.log

test -e vocab.en.yml
test -e vocab.de.yml
test -e valid/model.npz
test -e valid/model.npz.yml
test -e valid/model.npz.amun.yml
test -e valid/model.npz.dev.npz
test -e valid/model.npz.dev.npz.amun.yml

test -e valid.log

$MRT_TOOLS/strip-timestamps.sh < valid.log > valid.out
$MRT_TOOLS/diff-floats.py valid.out valid.expected -p 0.2 > valid.diff

# Exit with success code
exit 0
