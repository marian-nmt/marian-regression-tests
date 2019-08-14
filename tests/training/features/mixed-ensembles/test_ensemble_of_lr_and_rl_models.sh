#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf rightleft rightleft*.log rightleft.out
mkdir -p rightleft

options="--no-shuffle --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --disp-freq 20 --after-batches 10"

# Train left-right model
$MRT_MARIAN/marian \
    --type s2s -m rightleft/model.lr.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    $options --seed 1111 --dim-emb 64 --dim-rnn 128 \
    --log rightleft_lr.log

test -e rightleft/model.lr.npz
test -e rightleft_lr.log

# Train right-left model
$MRT_MARIAN/marian --right-left \
    --type s2s -m rightleft/model.rl.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    $options --seed 2222 --dim-emb 64 --dim-rnn 128 \
    --log rightleft_rl.log

test -e rightleft/model.rl.npz
test -e rightleft_rl.log

# Check if an ensemble of a left-right and right-left model returns error message
$MRT_MARIAN/marian-decoder -m rightleft/model.lr.npz rightleft/model.rl.npz -v vocab.en.yml vocab.de.yml \
    -i text.in -o rightleft.out > rightleft.log 2>&1 || true

test -e rightleft.log
grep -qi "left-to-right and right-to-left models cannot be used together" rightleft.log

# Check if an ensemble of three right-left models works
$MRT_MARIAN/marian-decoder -m rightleft/model.{rl,rl,rl}.npz --weights 1 2 .5 -v vocab.en.yml vocab.de.yml \
    -i text.in -o rightleftx3.out --log rightleftx3.log

test -e rightleftx3.log
test -s rightleftx3.out

# Exit with success code
exit 0
