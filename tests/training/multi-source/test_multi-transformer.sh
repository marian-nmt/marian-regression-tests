#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf multi-transformer multi-transformer.log
mkdir -p multi-transformer

$MRT_MARIAN/build/marian \
    --seed 1111 --no-shuffle \
    --type multi-transformer --dim-emb 128 --dim-rnn 256 \
    -m multi-transformer/model.npz -t train.bpe.{en,xx,de} -v vocab.en.yml vocab.xx.yml vocab.de.yml \
    --disp-freq 20 --after-batches 100 \
    --log multi-transformer.log

test -e multi-transformer/model.npz
test -e multi-transformer/model.npz.yml
test -e multi-transformer.log

cat multi-transformer.log | grep 'Ep\. 1 :' | $MRT_TOOLS/extract-costs.sh > multi-transformer.out
$MRT_TOOLS/diff-floats.py multi-transformer.out multi-transformer.expected -p 0.5 > multi-transformer.diff

# Exit with success code
exit 0
