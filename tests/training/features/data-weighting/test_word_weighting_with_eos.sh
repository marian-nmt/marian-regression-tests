#!/bin/bash

#####################################################################
# SUMMARY:
# TAGS: dataweights
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf word_eos word_eos.{log,out,diff}
mkdir -p word_eos

# Generate word weights, each word has weight 2, including EOS
cat $MRT_DATA/europarl.de-en/toy.bpe.en | sed -r -e 's/[^ ]+/2/g' -e 's/$/ 2/' > word_eos.weights.txt

# Train
$MRT_MARIAN/marian \
    --seed 1111 --no-shuffle --dim-emb 128 --dim-rnn 256 --optimizer sgd --cost-type ce-mean \
    -m word_eos/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v vocab.{de,en}.yml \
    --log word_eos.log --disp-freq 5 -e 2 \
    --data-weighting word_eos.weights.txt --data-weighting-type word

test -e word_eos/model.npz
test -e word_eos.log

cat word_eos.log | $MRT_TOOLS/extract-disp.sh > word_eos.out
$MRT_TOOLS/diff-nums.py word_eos.out word_eos.expected -p 0.1 -o word_eos.diff


# Exit with success code
exit 0
