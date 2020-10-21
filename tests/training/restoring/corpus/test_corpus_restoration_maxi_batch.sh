#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf corpus_maxi corpus_maxi*.log
mkdir -p corpus_maxi

test -e vocab.de.yml
test -e vocab.en.yml

extra_opts="--seed 1111 --maxi-batch 20 --mini-batch 32 --optimizer sgd --dim-emb 128 --dim-rnn 256 --disp-freq 4"
# Added because default options has changes
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"

$MRT_MARIAN/marian \
    -m corpus_maxi/model_full.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 70 $extra_opts \
    --log corpus_maxi.log

test -e corpus_maxi/model_full.npz
test -e corpus_maxi.log

cat corpus_maxi.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_maxi.expected

$MRT_MARIAN/marian \
    -m corpus_maxi/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 40 $extra_opts \
    --log corpus_maxi_1.log

test -e corpus_maxi/model.npz
test -e corpus_maxi/model.npz.progress.yml
test -e corpus_maxi_1.log

cat corpus_maxi_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_maxi_1.out
cp corpus_maxi/model.npz.yml corpus_maxi/model.npz.yml.bac
cp corpus_maxi/model.npz.progress.yml corpus_maxi/model.npz.progress.yml.bac

$MRT_MARIAN/marian \
    -m corpus_maxi/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 70 $extra_opts \
    --log corpus_maxi_2.log

test -e corpus_maxi/model.npz
test -e corpus_maxi_2.log

cat corpus_maxi_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_maxi_2.out
cat corpus_maxi_1.out corpus_maxi_2.out > corpus_maxi.out

$MRT_TOOLS/diff-nums.py corpus_maxi.out corpus_maxi.expected -p 0.1 -o corpus_maxi.diff

# Exit with success code
exit 0
