#!/bin/bash -x

#####################################################################
# SUMMARY: Train using the 'ce-sum' cost function
# AUTHOR: snukky
# TAGS: gcc5-fails sync-sgd
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf ce-sum ce-sum.log
mkdir -p ce-sum

$MRT_MARIAN/marian \
    --cost-type ce-sum --disp-label-counts false \
    --seed 9999 --optimizer sgd --sync-sgd \
    -m ce-sum/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 2 --after-epochs 1 \
    --log ce-sum.log

test -e ce-sum/model.npz
test -e ce-sum.log

cat ce-sum.log | grep 'Ep\. 1 :' | $MRT_TOOLS/extract-costs.sh > ce-sum.out
$MRT_TOOLS/diff-nums.py ce-sum.out ce-sum.expected -p 0.2 -o ce-sum.diff

# Exit with success code
exit 0
