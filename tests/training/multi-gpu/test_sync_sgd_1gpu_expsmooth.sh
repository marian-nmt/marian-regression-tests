#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf sync_sgd_1gpu_expsmooth sync_sgd_1gpu_expsmooth.log
mkdir -p sync_sgd_1gpu_expsmooth

$MRT_MARIAN/marian \
    --no-shuffle --seed 888 --mini-batch 4 --maxi-batch 1 --maxi-batch-sort none \
    --dim-rnn 64 --dim-emb 32 --learn-rate 0.1 \
    --devices 0 --sync-sgd --optimizer sgd --exponential-smoothing --cost-type ce-mean \
    -m sync_sgd_1gpu_expsmooth/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 5 --save-freq 10 --after-batches 20 \
    --log sync_sgd_1gpu_expsmooth.log

test -e sync_sgd_1gpu_expsmooth/model.npz
test -e sync_sgd_1gpu_expsmooth.log

cat sync_sgd_1gpu_expsmooth.log | $MRT_TOOLS/extract-costs.sh > sync_sgd_1gpu_expsmooth.out
$MRT_TOOLS/diff-nums.py sync_sgd_1gpu_expsmooth.out sync_sgd_1gpu_expsmooth.expected -o sync_sgd_1gpu_expsmooth.diff

# Exit with success code
exit 0
