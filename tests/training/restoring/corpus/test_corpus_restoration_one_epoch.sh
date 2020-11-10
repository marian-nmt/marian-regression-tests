#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf corpus_one corpus_one*.log
mkdir -p corpus_one

test -e vocab.de.yml
test -e vocab.en.yml

extra_opts="--seed 9999 --maxi-batch 1 --maxi-batch-sort none --mini-batch 32 --optimizer sgd --dim-emb 128 --dim-rnn 256 --disp-freq 4"
# Added because default options has changes
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"

$MRT_MARIAN/marian \
    -m corpus_one/model_full.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 70 $extra_opts \
    --log corpus_one.log

test -e corpus_one/model_full.npz
test -e corpus_one.log

cat corpus_one.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_one.expected

$MRT_MARIAN/marian \
    -m corpus_one/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 25 $extra_opts \
    --log corpus_one_1.log

test -e corpus_one/model.npz
test -e corpus_one_1.log

cat corpus_one_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_one_1.out
cp corpus_one/model.npz.yml corpus_one/model.npz.1.yml

$MRT_MARIAN/marian \
    -m corpus_one/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 70 $extra_opts \
    --log corpus_one_2.log

test -e corpus_one/model.npz
test -e corpus_one_2.log

cat corpus_one_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_one_2.out
cat corpus_one_1.out corpus_one_2.out > corpus_one.out

$MRT_TOOLS/diff-nums.py corpus_one.out corpus_one.expected -p 0.1 -o corpus_one.diff

# Exit with success code
exit 0
