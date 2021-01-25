#!/bin/bash

#####################################################################
# SUMMARY:
# TAGS: dataweights
#####################################################################

# Exit on error
set -e

# Test code goes here
mkdir -p word_maxibatch
rm -rf word_maxibatch/* word_maxibatch.log

test -e vocab.de.yml || $MRT_MARIAN/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.de > vocab.de.yml
test -e vocab.en.yml || $MRT_MARIAN/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.en > vocab.en.yml

$MRT_MARIAN/marian \
    --seed 6666 --no-shuffle --dim-emb 128 --dim-rnn 256 --optimizer sgd \
    -m word_maxibatch/model.npz -t train.1k.{de,en} -v vocab.{de,en}.yml \
    --log word_maxibatch.log --disp-freq 10 --after-batches 100 --mini-batch 16 --cost-type ce-mean \
    --data-weighting train.1k.wordinc.txt --data-weighting-type word

test -e word_maxibatch/model.npz
test -e word_maxibatch.log

$MRT_TOOLS/extract-costs.sh < word_maxibatch.log > word_maxibatch.out
$MRT_TOOLS/diff-nums.py word_maxibatch.out word_maxibatch.expected -p 0.1 -o word_maxibatch.diff

# Exit with success code
exit 0
