#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf adagrad adagrad*.log
mkdir -p adagrad

$MRT_MARIAN/marian \
    --no-shuffle --seed 7777 --maxi-batch 1 --maxi-batch-sort none --dim-emb 128 --dim-rnn 256 \
    -m adagrad/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 --save-freq 60 --optimizer adagrad --cost-type ce-mean \
    --log adagrad.log

test -e adagrad/model.npz
test -e adagrad/model.npz.optimizer.npz
test -e adagrad.log

$MRT_TOOLS/extract-costs.sh < adagrad.log > adagrad.costs.out
$MRT_TOOLS/diff-nums.py adagrad.costs.out adagrad.costs.expected -p 0.2 -o adagrad.costs.diff

python3 $MRT_MARIAN/../scripts/contrib/model_info.py -m adagrad/model.npz.optimizer.npz > adagrad.keys.out
$MRT_TOOLS/diff.sh adagrad.keys.out adagrad.keys.expected > adagrad.keys.diff

python3 $MRT_MARIAN/../scripts/contrib/model_info.py -m adagrad/model.npz.optimizer.npz -k "adagrad_gt" > adagrad.gt.out
$MRT_TOOLS/diff-nums.py --numpy -p 0.001 adagrad.gt.out adagrad.gt.expected -o adagrad.gt.diff

# Exit with success code
exit 0
