#!/bin/bash

# Exit on error
set -eo pipefail

# Test code goes here
mkdir -p maxibatch
rm -rf maxibatch/* maxibatch.log

test -e vocab.de.yml || $MRT_MARIAN/build/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.de > vocab.de.yml
test -e vocab.en.yml || $MRT_MARIAN/build/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.en > vocab.en.yml

$MRT_MARIAN/build/marian \
    --seed 3333 --no-shuffle --dim-emb 128 --dim-rnn 256 -o sgd \
    -m maxibatch/model.npz -t train.1k.{de,en} -v vocab.{de,en}.yml \
    --log maxibatch.log --disp-freq 10 --after-batches 100 --mini-batch 16 --cost-type ce-sum \
    --data-weighting train.1k.inc.txt --data-weighting-type sentence

test -e maxibatch/model.npz
test -e maxibatch.log

$MRT_TOOLS/extract-costs.sh < maxibatch.log > maxibatch.out
$MRT_TOOLS/diff-floats.py $(pwd)/maxibatch.out $(pwd)/maxibatch.expected -p 0.1 | tee $(pwd)/maxibatch.diff | head

# Exit with success code
exit 0
