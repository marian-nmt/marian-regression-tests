#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf rightleft rightleft*.log rightleft.out
mkdir -p rightleft

options="--no-shuffle --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --disp-freq 20 --after-batches 10"

# Train model A
$MRT_MARIAN/marian \
    --type s2s -m rightleft/model.lr.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    $options --seed 1111 --dim-emb 64 --dim-rnn 128 \
    --log rightleft_lr.log

test -e rightleft/model.lr.npz
test -e rightleft_lr.log

# Train model B with different architecture
$MRT_MARIAN/marian --right-left \
    --type s2s -m rightleft/model.rl.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    $options --seed 2222 --dim-emb 64 --dim-rnn 128 \
    --log rightleft_rl.log

test -e rightleft/model.rl.npz
test -e rightleft_rl.log

# Check if the ensemble of two different s2s models works
$MRT_MARIAN/marian-decoder -m rightleft/model.lr.npz rightleft/model.rl.npz -v vocab.en.yml vocab.de.yml \
    -i text.in -o rightleft.out > rightleft.log 2>&1 || true

test -e rightleft.log
grep -q "left-to-right and right-to-left model* cannot be decoded together" rightleft.log

# Exit with success code
exit 0
