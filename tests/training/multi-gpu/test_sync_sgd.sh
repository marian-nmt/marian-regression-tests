#!/bin/bash -x

# Exit on error
set -e

if (( $MRT_NUM_DEVICES < 2 )); then
    echo "Too few devices available"
    exit 100
fi

# Test code goes here
rm -rf sync_sgd sync_sgd.log
mkdir -p sync_sgd

$MRT_MARIAN/marian \
    --no-shuffle --seed 777 --mini-batch 4 --maxi-batch 1 --maxi-batch-sort none \
    --dim-rnn 64 --dim-emb 32 --learn-rate 0.001 --clip-norm 0 \
    --devices 0 1 --sync-sgd --optimizer sgd --cost-type ce-mean \
    -m sync_sgd/model.full.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 \
    --log sync_sgd.log

test -e sync_sgd/model.full.npz
test -e sync_sgd.log

cat sync_sgd.log | $MRT_TOOLS/extract-costs.sh > sync_sgd.out
$MRT_TOOLS/diff-nums.py sync_sgd.out sync_sgd.expected -p 0.0001 -o sync_sgd.diff

# Exit with success code
exit 0
