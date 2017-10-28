#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf dynamic dynamic.log
mkdir -p dynamic

$MRT_MARIAN/build/marian \
    --no-shuffle \
    -m dynamic/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.en $MRT_DATA/europarl.de-en/corpus.bpe.de \
    -v vocab.en.yml vocab.de.yml \
    --disp-freq 20 --after-batches 100 \
    --seed 1111 \
    --log dynamic.log \
    --mini-batch-fit -w 4000

test -e vocab.en.yml
test -e vocab.de.yml
test -e dynamic/model.npz
test -e dynamic/model.npz.yml
test -e dynamic/model.npz.amun.yml

test -e dynamic.log

cat dynamic.log | grep 'Ep\. 1 :' | sed -r 's/.*Up\. ([0-9]+) .*Sen. ([0-9]+).*/\2\/\1/' | bc > dynamic.out
diff dynamic.out dynamic.expected > dynamic.diff

# Exit with success code
exit 0
