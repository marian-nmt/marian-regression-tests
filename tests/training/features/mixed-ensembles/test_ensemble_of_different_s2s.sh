#!/bin/bash -x

#####################################################################
# SUMMARY: Train and decode with RNN models of different architectures
# AUTHOR: snukky
# TAGS: unstable
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf two_s2s two_s2s*.log
mkdir -p two_s2s

options="--no-shuffle --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --disp-freq 20 --after-batches 100"

# Train model A
$MRT_MARIAN/marian \
    --type s2s -m two_s2s/modelA.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    $options --seed 1111 --dim-emb 128 --dim-rnn 256 \
    --log two_s2s_A.log

test -e two_s2s/modelA.npz
test -e two_s2s_A.log

# Train model B with different architecture
$MRT_MARIAN/marian \
    --type s2s -m two_s2s/modelB.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    $options --seed 2222 --dim-emb 256 --dim-rnn 128 --layer-normalization --enc-depth 2 \
    --log two_s2s_B.log

test -e two_s2s/modelB.npz
test -e two_s2s_B.log

# Check if the ensemble of two different s2s models works
$MRT_MARIAN/marian-decoder -m two_s2s/modelA.npz two_s2s/modelB.npz -v vocab.en.yml vocab.de.yml \
    -b 4 -i text.in -o two_s2s.out --log two_s2s.log

$MRT_TOOLS/diff.sh two_s2s.out two_s2s.expected > two_s2s.diff

# Exit with success code
exit 0
