#!/bin/bash -x

#####################################################################
# SUMMARY: Train using the 'ce-mean' cost function
# AUTHOR: snukky
# TAGS: gcc5-fails sync-sgd
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf ce-mean ce-mean.log
mkdir -p ce-mean

$MRT_MARIAN/marian \
    --cost-type ce-mean \
    --seed 9999 --sync-sgd \
    -m ce-mean/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 2 --after-epochs 1 \
    --log ce-mean.log

test -e ce-mean/model.npz
test -e ce-mean.log

cat ce-mean.log | grep 'Ep\. 1 :' | $MRT_TOOLS/extract-costs.sh > ce-mean.out
$MRT_TOOLS/diff-nums.py ce-mean.out ce-mean.expected -p 0.02 -o ce-mean.diff

# Exit with success code
exit 0
