#!/bin/bash -x

#####################################################################
# SUMMARY: Train using perplexity as a cost function
# AUTHOR: snukky
# TAGS: unstable gcc5-fails sync-sgd
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf perplexity perplexity.log
mkdir -p perplexity

$MRT_MARIAN/marian \
    --cost-type perplexity \
    --seed 9999 --optimizer sgd --sync-sgd \
    -m perplexity/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 2 --after-epochs 1 \
    --log perplexity.log

test -e perplexity/model.npz
test -e perplexity.log

cat perplexity.log | grep 'Ep\. 1 :' | $MRT_TOOLS/extract-costs.sh > perplexity.out
$MRT_TOOLS/diff-nums.py perplexity.out perplexity.expected -p 0.2 -o perplexity.diff

# Exit with success code
exit 0
