#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf corpus corpus*.log
mkdir -p corpus

test -e vocab.de.yml
test -e vocab.en.yml

extra_opts="--seed 1111 --maxi-batch 1 --maxi-batch-sort none --mini-batch 32 --optimizer sgd --dim-emb 128 --dim-rnn 256 --disp-freq 4"

$MRT_MARIAN/marian \
    -m corpus/model_full.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 70 $extra_opts \
    --log corpus.log

test -e corpus/model_full.npz
test -e corpus.log

cat corpus.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus.expected

$MRT_MARIAN/marian \
    -m corpus/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 40 $extra_opts \
    --log corpus_1.log

test -e corpus/model.npz
test -e corpus_1.log

cat corpus_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_1.out
cp corpus/model.npz.yml corpus/model.npz.1.yml

$MRT_MARIAN/marian \
    -m corpus/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 70 $extra_opts \
    --log corpus_2.log

test -e corpus/model.npz
test -e corpus_2.log

cat corpus_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_2.out
cat corpus_1.out corpus_2.out > corpus.out

$MRT_TOOLS/diff-nums.py corpus.out corpus.expected -p 0.1 -o corpus.diff

# Exit with success code
exit 0
