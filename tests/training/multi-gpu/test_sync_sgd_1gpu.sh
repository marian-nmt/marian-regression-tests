#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf sync_sgd_1gpu sync_sgd_1gpu.log
mkdir -p sync_sgd_1gpu

$MRT_MARIAN/marian \
    --no-shuffle --seed 888 --mini-batch 4 --maxi-batch 1 --maxi-batch-sort none \
    --dim-rnn 64 --dim-emb 32 --learn-rate 0.1 \
    --devices 0 --sync-sgd --optimizer sgd --cost-type ce-mean \
    -m sync_sgd_1gpu/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 5 --save-freq 10 --after-batches 20 \
    --log sync_sgd_1gpu.log

test -e sync_sgd_1gpu/model.npz
test -e sync_sgd_1gpu.log

cat sync_sgd_1gpu.log | $MRT_TOOLS/extract-costs.sh > sync_sgd_1gpu.out
$MRT_TOOLS/diff-nums.py sync_sgd_1gpu.out sync_sgd_1gpu.expected -o sync_sgd_1gpu.diff

# Exit with success code
exit 0
