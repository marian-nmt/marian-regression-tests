#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf perplexity perplexity.log
mkdir -p perplexity

# @TODO: investigate where thie instability comes from, open issue: https://github.com/marian-nmt/marian-dev/issues/421

$MRT_MARIAN/marian \
    --cost-type perplexity \
    --seed 9999 \
    -m perplexity/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 2 --after-epochs 1 \
    --log perplexity.log

test -e perplexity/model.npz
test -e perplexity.log

cat perplexity.log | grep 'Ep\. 1 :' | $MRT_TOOLS/extract-costs.sh > perplexity.out
$MRT_TOOLS/diff-nums.py perplexity.out perplexity.expected -p 5 -o perplexity.diff

# Exit with success code
exit 0
