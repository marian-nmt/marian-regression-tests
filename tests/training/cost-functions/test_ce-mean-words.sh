#!/bin/bash -x

# Exit on error
set -eo pipefail

# Test code goes here
rm -rf ce-mean-words ce-mean-words.log
mkdir -p ce-mean-words

$MRT_MARIAN/build/marian \
    --cost-type ce-mean-words \
    --seed 9999 \
    -m ce-mean-words/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 2 --after-epoch 1 \
    --log ce-mean-words.log

test -e ce-mean-words/model.npz
test -e ce-mean-words.log

cat ce-mean-words.log | grep 'Ep\. 1 :' | $MRT_TOOLS/extract-costs.sh > ce-mean-words.out
$MRT_TOOLS/diff-floats.py $(pwd)/ce-mean-words.out $(pwd)/ce-mean-words.expected -p 0.02 | tee $(pwd)/ce-mean-words.diff | head

# Exit with success code
exit 0
