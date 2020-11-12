#!/bin/bash

#####################################################################
# SUMMARY:
# TAGS: dataweights
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf compare compare.{words.log,sents.log,out,diff}
mkdir -p compare

cat $MRT_DATA/europarl.de-en/toy.bpe.en | sed -r -e 's/[^ ]+/3/g' -e 's/$/ 3/' > compare.words.weights.txt
cat $MRT_DATA/europarl.de-en/toy.bpe.en | sed -r -e 's/.*/3/' > compare.sents.weights.txt

# Train on sentence-level, each sentence has weight 3
$MRT_MARIAN/marian \
    --seed 3333 --no-shuffle --dim-emb 128 --dim-rnn 256 --optimizer sgd \
    -m compare/model.sents.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v vocab.{de,en}.yml \
    --log compare.sents.log --disp-freq 5 -e 2 \
    --data-weighting compare.sents.weights.txt --data-weighting-type sentence

test -e compare/model.sents.npz
test -e compare.sents.log

cat compare.sents.log | $MRT_TOOLS/extract-disp.sh > compare.sents.out

# Train on word-level, each word has weight 3, including EOS
$MRT_MARIAN/marian \
    --seed 3333 --no-shuffle --dim-emb 128 --dim-rnn 256 --optimizer sgd \
    -m compare/model.words.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v vocab.{de,en}.yml \
    --log compare.words.log --disp-freq 5 -e 2 \
    --data-weighting compare.words.weights.txt --data-weighting-type word

test -e compare/model.words.npz
test -e compare.words.log

cat compare.words.log | $MRT_TOOLS/extract-disp.sh > compare.words.out
$MRT_TOOLS/diff-nums.py compare.words.out compare.sents.out -p 0.05 -o compare.words.diff


# Exit with success code
exit 0
