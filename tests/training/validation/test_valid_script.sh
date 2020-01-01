#!/bin/bash -x

#####################################################################
# SUMMARY: Test validation with a custom validation script
# AUTHOR: snukky
# TAGS: valid
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf valid valid.log valid_script.temp
mkdir -p valid

$MRT_MARIAN/marian \
    --seed 2222 --no-shuffle --dim-emb 128 --dim-rnn 256 --maxi-batch 1 --mini-batch 16 \
    -m valid/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} \
    -v vocab.50k.en.yml vocab.50k.de.yml --dim-vocabs 50000 50000 \
    --disp-freq 5 --valid-freq 15 --after-batches 75 \
    --valid-metrics cross-entropy valid-script \
    --valid-script-path ./valid_script.sh \
    --valid-sets $MRT_DATA/europarl.de-en/toy.bpe.{en,de} \
    --valid-log valid.log

test -e valid/model.npz
test -e valid/model.npz.yml
test -e valid/model.npz.amun.yml
test -e valid/model.npz.dev.npz
test -e valid/model.npz.dev.npz.amun.yml

test -e valid.log

$MRT_TOOLS/strip-timestamps.sh < valid.log > valid.out
$MRT_TOOLS/diff-nums.py valid.out valid.expected -p 0.2 -o valid.diff

# Exit with success code
exit 0
