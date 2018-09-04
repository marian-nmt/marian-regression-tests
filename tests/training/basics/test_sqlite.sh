#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf sqlite *sqlite.log
mkdir -p sqlite

$MRT_MARIAN/build/marian \
    --seed 1111 --no-shuffle --dim-emb 64 --dim-rnn 128 -o sgd \
    -m sqlite/model.nosqlite.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} \
    -v sqlite/vocab.en.yml sqlite/vocab.de.yml \
    --disp-freq 10 --after-batches 100 \
    --log nosqlite.log

test -e sqlite/model.nosqlite.npz
test -e nosqlite.log

$MRT_TOOLS/extract-costs.sh < nosqlite.log > nosqlite.out

$MRT_MARIAN/build/marian \
    --seed 1111 --no-shuffle --dim-emb 64 --dim-rnn 128 -o sgd \
    -m sqlite/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} --sqlite \
    -v sqlite/vocab.en.yml sqlite/vocab.de.yml \
    --disp-freq 10 --after-batches 100 \
    --log sqlite.log

test -e sqlite/model.npz
test -e sqlite.log

$MRT_TOOLS/extract-costs.sh < sqlite.log > sqlite.out

$MRT_TOOLS/diff-floats.py $(pwd)/nosqlite.out $(pwd)/sqlite.out -p 0.2 | tee $(pwd)/sqlite.diff | head

# Exit with success code
exit 0
