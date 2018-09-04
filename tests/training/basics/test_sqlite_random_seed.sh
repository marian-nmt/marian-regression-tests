#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf sqlite_seed sqlite_seed_?.log
mkdir -p sqlite_seed

$MRT_MARIAN/build/marian \
    --seed 3333 --dim-emb 64 --dim-rnn 128 -o sgd \
    -m sqlite_seed/model1.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} --sqlite \
    -v sqlite_seed/vocab.en.yml sqlite_seed/vocab.de.yml \
    --disp-freq 2 --after-batches 50 \
    --log sqlite_seed_1.log

test -e sqlite_seed/model1.npz
test -e sqlite_seed_1.log

$MRT_MARIAN/build/marian \
    --seed 3333 --dim-emb 64 --dim-rnn 128 -o sgd \
    -m sqlite_seed/model2.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} --sqlite \
    -v sqlite_seed/vocab.en.yml sqlite_seed/vocab.de.yml \
    --disp-freq 2 --after-batches 50 \
    --log sqlite_seed_2.log

test -e sqlite_seed/model2.npz
test -e sqlite_seed_2.log

$MRT_TOOLS/extract-costs.sh < sqlite_seed_1.log > sqlite_seed_1.out
$MRT_TOOLS/extract-costs.sh < sqlite_seed_2.log > sqlite_seed_2.out

$MRT_TOOLS/diff-floats.py sqlite_seed_1.out sqlite_seed_2.out -p 0.1 > sqlite_seed.diff

# Exit with success code
exit 0
