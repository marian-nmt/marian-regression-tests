#!/bin/bash

#####################################################################
# SUMMARY:
# TAGS: dataweights
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf warn warn.log warn.weights.txt
mkdir -p warn


cat $MRT_DATA/europarl.de-en/toy.bpe.en | sed -r 's/[^ ]+/1/g' > warn.weights.txt
sed -i '2s/1 1 /1 /g' warn.weights.txt
sed -i '3s/1 /1 1 /g' warn.weights.txt

$MRT_MARIAN/marian \
    --seed 1111 --dim-emb 64 --dim-rnn 128 --optimizer sgd -e 1 \
    -m warn/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v vocab.{de,en}.yml \
    --data-weighting warn.weights.txt --data-weighting-type word \
    > warn.log 2>&1 || true

test -e warn.log
grep -qi "[warn].*number of weights.* does not match.* words.* line #1" warn.log
grep -qi "[warn].*number of weights.* does not match.* words.* line #2" warn.log


# Exit with success code
exit 0
