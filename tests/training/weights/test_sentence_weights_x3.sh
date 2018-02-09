#!/bin/bash

# Exit on error
set -e

# Test code goes here
rm -rf x3copied* x3weights*
mkdir -p x3copied x3weights

test -e vocab.de.yml || $MRT_MARIAN/build/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.de > vocab.de.yml
test -e vocab.en.yml || $MRT_MARIAN/build/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.en > vocab.en.yml

$MRT_MARIAN/build/marian \
    --seed 2222 --no-shuffle --maxi-batch 1 --maxi-batch-sort none --max-length 100 \
    -m x3copied/model.npz -t train.x3.{de,en} -v vocab.{de,en}.yml \
    --log x3copied.log --disp-freq 1 --after-batches 100 1 --mini-batch 4 --cost-type ce-sum

test -e x3copied/model.npz
test -e x3copied.log
cat x3copied.log | grep 'Cost ' | sed -r 's/.*Cost (.*) : Time.*/\1/' > x3copied.out

$MRT_MARIAN/build/marian \
    --seed 2222 --no-shuffle --maxi-batch 1 --maxi-batch-sort none --max-length 100 \
    -m x3weights/model.npz -t train.1k.{de,en} -v vocab.{de,en}.yml \
    --log x3weights.log --disp-freq 1 --after-batches 100 --mini-batch 2 --cost-type ce-sum \
    --data-weighting train.1k.weights.txt --data-weighting-type sentence

test -e x3weights/model.npz
test -e x3weights.log

cat x3weights.log | grep 'Cost ' | sed -r 's/.*Cost (.*) : Time.*/\1/' > x3weights.out

$MRT_TOOLS/diff-floats.py x3copied.out x3weights.out -p 0.99 > x3weights.diff

# Exit with success code
exit 0
