#!/bin/bash -x

#####################################################################
# SUMMARY:
# TAGS: mini-batch-fit
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf corpus_noshuf corpus_noshuf*.log
mkdir -p corpus_noshuf

test -e vocab.de.yml
test -e vocab.en.yml

extra_opts="--seed 1234 --no-shuffle --maxi-batch 8 --maxi-batch-sort src --mini-batch 32 --mini-batch-fit -w 100 --optimizer sgd --dim-emb 128 --dim-rnn 256 --disp-freq 4"
# Added because default options has changes
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"

$MRT_MARIAN/marian \
    -m corpus_noshuf/model_full.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 80 $extra_opts \
    --log corpus_noshuf.log

test -e corpus_noshuf/model_full.npz
test -e corpus_noshuf.log

cat corpus_noshuf.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_noshuf.expected

$MRT_MARIAN/marian \
    -m corpus_noshuf/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 60 $extra_opts \
    --log corpus_noshuf_1.log

test -e corpus_noshuf/model.npz
test -e corpus_noshuf_1.log

cat corpus_noshuf_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_noshuf_1.out
cp corpus_noshuf/model.npz.yml corpus_noshuf/model.npz.1.yml
cp corpus_noshuf/model.npz.progress.yml corpus_noshuf/model.npz.progress.1.yml

$MRT_MARIAN/marian \
    -m corpus_noshuf/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 80 $extra_opts \
    --log corpus_noshuf_2.log

test -e corpus_noshuf/model.npz
test -e corpus_noshuf_2.log

cat corpus_noshuf_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_noshuf_2.out
cat corpus_noshuf_1.out corpus_noshuf_2.out > corpus_noshuf.out

$MRT_TOOLS/diff-nums.py corpus_noshuf.out corpus_noshuf.expected -p 0.1 -o corpus_noshuf.diff

# Exit with success code
exit 0
