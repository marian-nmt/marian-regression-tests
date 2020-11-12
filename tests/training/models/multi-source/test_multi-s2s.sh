#!/bin/bash -x

#####################################################################
# SUMMARY: Train a multi-source RNN model
# AUTHOR: snukky
# TAGS: multisource rnn
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf multi-s2s multi-s2s.log
mkdir -p multi-s2s

$MRT_MARIAN/marian \
    --seed 1111 --no-shuffle \
    --type multi-s2s --dim-emb 128 --dim-rnn 256 --cost-type ce-mean \
    -m multi-s2s/model.npz -t train.bpe.{en,xx,de} -v vocab.en.yml vocab.xx.yml vocab.de.yml \
    --disp-freq 20 --after-batches 100 \
    --log multi-s2s.log

test -e multi-s2s/model.npz
test -e multi-s2s/model.npz.yml
test -e multi-s2s.log

cat multi-s2s.log | grep 'Ep\. 1 :' | $MRT_TOOLS/extract-costs.sh > multi-s2s.out
$MRT_TOOLS/diff-nums.py multi-s2s.out multi-s2s.expected -p 0.2 -o multi-s2s.diff

# Exit with success code
exit 0
