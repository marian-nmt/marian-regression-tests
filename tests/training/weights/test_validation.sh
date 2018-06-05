#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf valid valid_script.temp
mkdir -p valid

test -e vocab.de.yml || $MRT_MARIAN/build/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.de > vocab.de.yml
test -e vocab.en.yml || $MRT_MARIAN/build/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.en > vocab.en.yml

$MRT_MARIAN/build/marian \
    --seed 4444 --no-shuffle --maxi-batch 1 --maxi-batch-sort none \
    -m valid/model.npz -t train.1k.{de,en} -v vocab.{de,en}.yml \
    --disp-freq 5 --valid-freq 15 --after-batches 50 \
    --data-weighting train.1k.weights.txt --data-weighting-type sentence \
    --valid-metrics cross-entropy valid-script --valid-script-path ./valid_script.sh \
    --valid-sets $MRT_DATA/europarl.de-en/toy.bpe.{en,de} \
    --valid-log valid/valid.log --log valid/train.log

test -e valid/model.npz
test -e valid/valid.log
test -e valid/train.log

$MRT_TOOLS/strip-timestamps.sh < valid/valid.log > valid.out
$MRT_TOOLS/diff-floats.py valid.out valid.expected -p 1.99 > valid.diff

$MRT_TOOLS/extract-costs.sh < valid/train.log > train.out
$MRT_TOOLS/diff-floats.py train.out train.expected -p 1.99 > train.diff

# Exit with success code
exit 0
