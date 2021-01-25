#!/bin/bash

#####################################################################
# SUMMARY:
# TAGS: dataweights
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf word_noweights* word_ones*
mkdir -p word_noweights word_ones

$MRT_MARIAN/marian \
    --seed 1111 --no-shuffle --dim-emb 128 --dim-rnn 256 --optimizer sgd \
    -m word_noweights/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v vocab.{de,en}.yml \
    --log word_noweights.log --disp-freq 5 -e 2

test -e word_noweights/model.npz
test -e word_noweights.log
cat word_noweights.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed -r 's/ Time.*//' > word_noweights.out

cat $MRT_DATA/europarl.de-en/toy.bpe.en | sed -r 's/[^ ]+/1/g' > word_ones.weights.txt

$MRT_MARIAN/marian \
    --seed 1111 --no-shuffle --dim-emb 128 --dim-rnn 256 --optimizer sgd \
    -m word_ones/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v vocab.{de,en}.yml \
    --log word_ones.log --disp-freq 5 -e 2 \
    --data-weighting word_ones.weights.txt --data-weighting-type word

test -e word_ones/model.npz
test -e word_ones.log

cat word_ones.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed -r 's/ Time.*//' > word_ones.out
$MRT_TOOLS/diff-nums.py word_noweights.out word_ones.out -p 0.1 -o word_ones.diff

# Exit with success code
exit 0
