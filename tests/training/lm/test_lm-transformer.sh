#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf lm-transformer lm-transformer.log
mkdir -p lm-transformer

$MRT_MARIAN/build/marian \
    --seed 1111 --no-shuffle \
    --type lm-transformer --dim-emb 128 --dim-rnn 256 \
    -m lm-transformer/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.en -v vocab.en.yml \
    --disp-freq 20 --after-batches 100 \
    --log lm-transformer.log

test -e lm-transformer/model.npz
test -e lm-transformer/model.npz.yml
test -e lm-transformer.log

cat lm-transformer.log | grep 'Ep\. 1 :' | $MRT_TOOLS/extract-costs.sh > lm-transformer.out
$MRT_TOOLS/diff-floats.py lm-transformer.out lm-transformer.expected -p 0.02 > lm-transformer.diff

# Scoring with LM
test -s temp.bpe.en || tail $MRT_DATA/europarl.de-en/corpus.bpe.en > test.bpe.en

$MRT_MARIAN/build/marian-scorer -m lm-transformer/model.npz -t test.bpe.en -v vocab.en.yml > lm-transformer.scores.out
$MRT_TOOLS/diff-floats.py lm-transformer.scores.out lm-transformer.scores.expected -p 0.002 > lm-transformer.scores.diff

# Exit with success code
exit 0
