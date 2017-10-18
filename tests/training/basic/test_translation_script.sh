#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf trans trans.log trans_script.temp
mkdir -p trans

$MRT_MARIAN/build/marian \
    --no-shuffle \
    -m trans/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.en $MRT_DATA/europarl.de-en/corpus.bpe.de \
    -v vocab.en.yml vocab.de.yml \
    --dim-vocabs 50000 50000 \
    --disp-freq 30 --valid-freq 60 --after-batches 150 \
    --seed 2222 \
    --valid-metrics cross-entropy translation --valid-script-path ./trans_script.sh \
    --valid-sets trans.bpe.en trans.bpe.de \
    --valid-log trans.log

test -e vocab.en.yml
test -e vocab.de.yml
test -e trans/model.npz
test -e trans/model.npz.yml
test -e trans/model.npz.amun.yml

test -e trans.log

grep -q "/tmp/marian.*" trans_script.temp

$MRT_TOOLS/strip-timestamps.sh < trans.log | grep -v "Total translation time" > trans.out
$MRT_TOOLS/diff-floats.py trans.out trans.expected -p 0.2 > trans.diff

# Exit with success code
exit 0
