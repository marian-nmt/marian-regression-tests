#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf final_batch final_batch.log vocab.*.yml
mkdir -p final_batch

$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --optimizer sgd --dim-emb 64 --dim-rnn 128 \
    -m final_batch/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} \
    -v vocab.en.yml vocab.de.yml --dim-vocabs 50000 50000 \
    --disp-freq 30 --valid-freq 60 --after-batches 150 \
    --valid-metrics cross-entropy --valid-sets valid.bpe.{en,de} \
    --valid-log final_batch.log

test -e final_batch/model.npz
test -e final_batch.log

$MRT_TOOLS/strip-timestamps.sh < final_batch.log > final_batch.out
$MRT_TOOLS/diff-nums.py final_batch.out final_batch.expected -p 0.9 -o final_batch.diff

# Exit with success code
exit 0
