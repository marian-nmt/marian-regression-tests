#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf transformer transformer*.log
mkdir -p transformer

opts="--no-shuffle --seed 1111 --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --dim-emb 64 --dim-rnn 128 --cost-type ce-mean"

$MRT_MARIAN/marian \
    --type transformer -m transformer/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    $opts --disp-freq 10 --after-batches 100 \
    --log transformer.log

test -e transformer/model.npz
test -e transformer.log

cat transformer.log | $MRT_TOOLS/extract-costs.sh > transformer.out
$MRT_TOOLS/diff-nums.py transformer.out transformer.expected -p 0.01 -o transformer.diff

# Exit with success code
exit 0
