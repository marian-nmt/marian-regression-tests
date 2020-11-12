#!/bin/bash

#####################################################################
# SUMMARY:
# TAGS: dataweights mini-batch-fit
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf sqlite_word sqlite_word.{log,out,diff}
mkdir -p sqlite_word

cat $MRT_DATA/europarl.de-en/toy.bpe.en | sed -r 's/[^ ]+/2/g' > sqlite_word.weights.txt

$MRT_MARIAN/marian \
    --seed 1111 --no-shuffle --dim-emb 128 --dim-rnn 256 --optimizer sgd --cost-type ce-mean \
    -m sqlite_word/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v vocab.{de,en}.yml \
    --log sqlite_word.log --disp-freq 5 -e 2 --mini-batch-fit -w 500 \
    --data-weighting sqlite_word.weights.txt --data-weighting-type word --sqlite sqlite_word/corpus.sqlite3

test -e sqlite_word/model.npz
test -e sqlite_word/corpus.sqlite3
test -e sqlite_word.log

cat sqlite_word.log | $MRT_TOOLS/extract-costs.sh > sqlite_word.out
$MRT_TOOLS/diff-nums.py sqlite_word.out sqlite_word.expected -p 0.1 -o sqlite_word.diff

# Exit with success code
exit 0
