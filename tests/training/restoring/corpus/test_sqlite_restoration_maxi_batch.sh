#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf sqlite_maxi sqlite_maxi*.log
mkdir -p sqlite_maxi

test -e vocab.de.yml
test -e vocab.en.yml

extra_opts="--seed 4444 --maxi-batch 20 --mini-batch 32 --optimizer sgd --dim-emb 128 --dim-rnn 256 --disp-freq 4"
# Added because default options has changes
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"

$MRT_MARIAN/marian \
    -m sqlite_maxi/model_full.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 70 $extra_opts \
    --log sqlite_maxi.log

test -e sqlite_maxi/model_full.npz
test -e sqlite_maxi.log

cat sqlite_maxi.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > sqlite_maxi.expected

$MRT_MARIAN/marian \
    -m sqlite_maxi/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 40 $extra_opts \
    --log sqlite_maxi_1.log

test -e sqlite_maxi/model.npz
test -e sqlite_maxi_1.log

cat sqlite_maxi_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > sqlite_maxi_1.out
cp sqlite_maxi/model.npz.yml sqlite_maxi/model.npz.1.yml

$MRT_MARIAN/marian \
    -m sqlite_maxi/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 70 $extra_opts \
    --log sqlite_maxi_2.log

test -e sqlite_maxi/model.npz
test -e sqlite_maxi_2.log

cat sqlite_maxi_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > sqlite_maxi_2.out
cat sqlite_maxi_1.out sqlite_maxi_2.out > sqlite_maxi.out

$MRT_TOOLS/diff-nums.py sqlite_maxi.out sqlite_maxi.expected -p 0.1 -o sqlite_maxi.diff

# Exit with success code
exit 0
