#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf ce-sum ce-sum.log
mkdir -p ce-sum

$MRT_MARIAN/build/marian \
    --cost-type ce-sum \
    --seed 9999 \
    -m ce-sum/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 2 --after-epoch 1 \
    --log ce-sum.log

test -e ce-sum/model.npz
test -e ce-sum.log

cat ce-sum.log | grep 'Ep\. 1 :' | $MRT_TOOLS/extract-costs.sh > ce-sum.out
$MRT_TOOLS/diff-floats.py ce-sum.out ce-sum.expected -p 0.2 > ce-sum.diff

# Exit with success code
exit 0
