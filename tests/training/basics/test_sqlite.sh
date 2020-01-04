#!/bin/bash -x

#####################################################################
# SUMMARY: Training using SQLite is exactly the same as training using textual files
# AUTHOR: snukky
# TAGS: sqlite
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf sqlite *sqlite.log
mkdir -p sqlite

$MRT_MARIAN/marian \
    --seed 1111 --no-shuffle --dim-emb 64 --dim-rnn 128 --optimizer sgd \
    -m sqlite/model.nosqlite.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 \
    --log nosqlite.log

test -e sqlite/model.nosqlite.npz
test -e nosqlite.log

$MRT_TOOLS/extract-costs.sh < nosqlite.log > nosqlite.out

$MRT_MARIAN/marian \
    --seed 1111 --no-shuffle --dim-emb 64 --dim-rnn 128 --optimizer sgd \
    -m sqlite/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} --sqlite \
    -v sqlite/vocab.en.yml sqlite/vocab.de.yml \
    --disp-freq 10 --after-batches 100 \
    --log sqlite.log

test -e sqlite/model.npz
test -e sqlite.log

$MRT_TOOLS/extract-costs.sh < sqlite.log > sqlite.out

$MRT_TOOLS/diff-nums.py nosqlite.out sqlite.out -p 0.2 -o sqlite.diff

# Exit with success code
exit 0
