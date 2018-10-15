#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf transformer transformer*.log
mkdir -p transformer

opts="--no-shuffle --seed 1111 --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --dim-emb 64 --dim-rnn 128"

$MRT_MARIAN/build/marian \
    -m transformer/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    $opts --disp-freq 1 --after-batches 10 \
    --log transformer.log

test -e transformer/model.npz
test -e transformer.log

cat transformer.log | $MRT_TOOLS/extract-costs.sh > transformer.out
$MRT_TOOLS/diff-floats.py transformer.out transformer.expected -p 0.01 > transformer.diff

# Exit with success code
exit 0
