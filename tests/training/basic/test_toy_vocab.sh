#!/bin/bash

# Exit on error
set -e

# Test code goes here
mkdir -p toy
rm -f toy/* toy.log

$MRT_MARIAN/build/marian \
    -m toy/model.npz \
    -t $MRT_DATA/europarl.de-en/toy.bpe.en $MRT_DATA/europarl.de-en/toy.bpe.de \
    -v toy/vocab.en.yml toy/vocab.de.yml \
    --log toy.log --disp-freq 5 -e 5 \
    --seed 1111

test -e toy/vocab.en.yml
test -e toy/vocab.de.yml
test -e toy/model.npz
test -e toy/model.npz.yml
test -e toy/model.npz.amun.yml

cat toy.log | $MRT_TOOLS/extract-costs.sh > toy.out
$MRT_TOOLS/diff-floats.py toy.out toy.expected -p 0.9 > toy.diff

# Exit with success code
exit 0
