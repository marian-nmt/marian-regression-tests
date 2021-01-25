#!/bin/bash -x

#####################################################################
# SUMMARY: Train a RNN language model
# AUTHOR: snukky
# TAGS: lm rnn
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf lm lm.log
mkdir -p lm

$MRT_MARIAN/marian \
    --seed 1111 --no-shuffle \
    --type lm --dim-emb 128 --dim-rnn 256 --cost-type ce-mean \
    -m lm/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.en -v vocab.en.yml \
    --disp-freq 20 --after-batches 100 \
    --log lm.log

test -e lm/model.npz
test -e lm/model.npz.yml
test -e lm.log

cat lm.log | grep 'Ep\. 1 :' | $MRT_TOOLS/extract-costs.sh > lm.out
$MRT_TOOLS/diff-nums.py lm.out lm.expected -p 0.02 -o lm.diff

# Scoring with LM
test -s temp.bpe.en || tail $MRT_DATA/europarl.de-en/corpus.bpe.en > test.bpe.en

$MRT_MARIAN/marian-scorer -m lm/model.npz -t test.bpe.en -v vocab.en.yml > lm.scores.out
$MRT_TOOLS/diff-nums.py lm.scores.out lm.scores.expected -p 0.002 -o lm.scores.diff

# Exit with success code
exit 0
