#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf multi-s2s multi-s2s.log
mkdir -p multi-s2s

$MRT_MARIAN/build/marian \
    --seed 1111 --no-shuffle \
    --type multi-s2s --dim-emb 128 --dim-rnn 256 \
    -m multi-s2s/model.npz -t train.bpe.{en,xx,de} -v vocab.en.yml vocab.xx.yml vocab.de.yml \
    --disp-freq 20 --after-batches 100 \
    --log multi-s2s.log

test -e multi-s2s/model.npz
test -e multi-s2s/model.npz.yml
test -e multi-s2s.log

cat multi-s2s.log | grep 'Ep\. 1 :' | $MRT_TOOLS/extract-costs.sh > multi-s2s.out
$MRT_TOOLS/diff-floats.py multi-s2s.out multi-s2s.expected -p 0.5 > multi-s2s.diff

# Exit with success code
exit 0
