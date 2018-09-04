#!/bin/bash

# Exit on error
set -eo pipefail

# Test code goes here
mkdir -p toy
rm -f toy/* toy.log

$MRT_MARIAN/build/marian \
    --seed 1111 --dim-emb 256 --dim-rnn 512 \
    -m toy/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v toy/vocab.en.yml toy/vocab.de.yml \
    --log toy.log --disp-freq 5 -e 5

test -e toy/vocab.en.yml
test -e toy/vocab.de.yml
test -e toy/model.npz
test -e toy/model.npz.yml
test -e toy/model.npz.amun.yml

cat toy.log | $MRT_TOOLS/extract-costs.sh > toy.out
$MRT_TOOLS/diff-floats.py $(pwd)/toy.out $(pwd)/toy.expected -p 0.99 -n 5 | tee $(pwd)/toy.diff | head

# Exit with success code
exit 0
