#!/bin/bash

# Exit on error
set -e

# Test code goes here
mkdir -p maxibatch
rm -rf maxibatch/* maxibatch.log

$MRT_MARIAN/build/marian \
    --seed 3333 --no-shuffle \
    -m maxibatch/model.npz -t train.1k.{de,en} -v vocab.{de,en}.yml \
    --log maxibatch.log --disp-freq 10 --after-batches 100 --mini-batch 16 --cost-type ce-sum \
    --data-weighting train.1k.inc.txt --data-weighting-type sentence

test -e maxibatch/model.npz
test -e maxibatch.log

$MRT_TOOLS/extract-costs.sh < maxibatch.log > maxibatch.out
$MRT_TOOLS/diff-floats.py maxibatch.out maxibatch.expected -p 0.3 > maxibatch.diff

# Exit with success code
exit 0
