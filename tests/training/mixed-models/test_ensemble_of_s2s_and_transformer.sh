#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf s2s_transf s2s_transf*.log
mkdir -p s2s_transf

options="--no-shuffle --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --disp-freq 20 --after-batches 100"

# Train model A
$MRT_MARIAN/marian \
    --type s2s -m s2s_transf/modelA.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    $options --seed 1111 --dim-emb 128 --dim-rnn 256 \
    --log s2s_transf_A.log

test -e s2s_transf/modelA.npz
test -e s2s_transf_A.log

# Train model B with different architecture
$MRT_MARIAN/marian \
    --type transformer -m s2s_transf/modelB.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    $options --seed 2222 --dim-emb 256 --dim-rnn 128 \
    --log s2s_transf_B.log

test -e s2s_transf/modelB.npz
test -e s2s_transf_B.log

# Check if the ensemble of two different s2s models works
$MRT_MARIAN/marian-decoder -m s2s_transf/modelA.npz s2s_transf/modelB.npz -v vocab.en.yml vocab.de.yml \
    -i text.in -o s2s_transf.out --log s2s_transf.log

$MRT_TOOLS/diff.sh s2s_transf.out s2s_transf.expected > s2s_transf.diff

# Exit with success code
exit 0
