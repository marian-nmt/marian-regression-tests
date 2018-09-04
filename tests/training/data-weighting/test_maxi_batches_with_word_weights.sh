#!/bin/bash

# Exit on error
set -eo pipefail

# Test code goes here
mkdir -p word_maxibatch
rm -rf word_maxibatch/* word_maxibatch.log

test -e vocab.de.yml || $MRT_MARIAN/build/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.de > vocab.de.yml
test -e vocab.en.yml || $MRT_MARIAN/build/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.en > vocab.en.yml

$MRT_MARIAN/build/marian \
    --seed 6666 --no-shuffle --dim-emb 128 --dim-rnn 256 -o sgd \
    -m word_maxibatch/model.npz -t train.1k.{de,en} -v vocab.{de,en}.yml \
    --log word_maxibatch.log --disp-freq 10 --after-batches 100 --mini-batch 16 \
    --data-weighting train.1k.wordinc.txt --data-weighting-type word

test -e word_maxibatch/model.npz
test -e word_maxibatch.log

$MRT_TOOLS/extract-costs.sh < word_maxibatch.log > word_maxibatch.out
$MRT_TOOLS/diff-floats.py $(pwd)/word_maxibatch.out $(pwd)/word_maxibatch.expected -p 0.1 | tee $(pwd)/word_maxibatch.diff | head

# Exit with success code
exit 0
