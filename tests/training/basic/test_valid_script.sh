#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf valid valid.log valid_script.temp
mkdir -p valid

$MRT_MARIAN/build/marian -d $MRT_GPU \
    --no-shuffle \
    -m valid/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.en $MRT_DATA/europarl.de-en/corpus.bpe.de \
    -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --valid-freq 30 --after-batches 150 \
    --seed 2222 \
    --valid-metrics cross-entropy valid-script --valid-script-path ./valid_script.sh \
    --valid-sets $MRT_DATA/europarl.de-en/toy.bpe.en $MRT_DATA/europarl.de-en/toy.bpe.de \
    --valid-log valid.log

test -e vocab.en.yml
test -e vocab.de.yml
test -e valid/model.npz
test -e valid/model.npz.yml
test -e valid/model.npz.amun.yml
test -e valid/model.npz.dev.npz
test -e valid/model.npz.dev.npz.amun.yml

test -e valid.log

$MRT_TOOLS/strip-timestamps.sh < valid.log > valid.out
$MRT_TOOLS/diff-floats.py valid.out valid.expected -p 0.2 > valid.diff

# Exit with success code
exit 0
