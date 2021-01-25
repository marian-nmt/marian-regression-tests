#!/bin/bash

#####################################################################
# SUMMARY: Run a basic training command with tiny vocabs
# AUTHOR: snukky
# TAGS: small-vocab
#####################################################################

# Exit on error
set -e

# Test code goes here
mkdir -p tiny
rm -f tiny/* tiny.log

$MRT_MARIAN/marian \
    --seed 1111 --dim-emb 256 --dim-rnn 512 --no-shuffle --clip-norm 0 \
    -m tiny/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v tiny/vocab.de.yml tiny/vocab.en.yml \
    --log tiny.log --disp-freq 5 -e 5

test -e tiny/vocab.en.yml
test -e tiny/vocab.de.yml
test -e tiny/model.npz
test -e tiny/model.npz.yml
test -e tiny/model.npz.amun.yml

cat tiny.log | $MRT_TOOLS/extract-costs.sh > tiny.out
$MRT_TOOLS/diff-nums.py tiny.out tiny.expected -p 0.1 -o tiny.diff

# Exit with success code
exit 0
