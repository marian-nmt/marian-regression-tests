#!/bin/bash

# Exit on error
set -e

# Test code goes here
rm -rf gzip gzip.log
mkdir -p gzip

test -e $MRT_DATA/europarl.de-en/corpus.bpe.de.gz || cat $MRT_DATA/europarl.de-en/corpus.bpe.de | gzip > $MRT_DATA/europarl.de-en/corpus.bpe.de.gz
test -e $MRT_DATA/europarl.de-en/corpus.bpe.en.gz || cat $MRT_DATA/europarl.de-en/corpus.bpe.en | gzip > $MRT_DATA/europarl.de-en/corpus.bpe.en.gz

$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 64 --dim-rnn 64 \
    -m gzip/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de}.gz -v vocab.en.yml vocab.de.yml \
    --log gzip.log --disp-freq 10 --after-batches 50

test -e gzip/model.npz
test -e gzip.log

cat gzip.log | $MRT_TOOLS/extract-costs.sh > gzip.out
$MRT_TOOLS/diff-nums.py gzip.out gzip.expected -p 0.1 -o gzip.diff

# Exit with success code
exit 0
