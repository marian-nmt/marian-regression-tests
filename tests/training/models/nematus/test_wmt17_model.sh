#!/bin/bash

# Exit on error
set -e

# Test code goes here
mkdir -p wmt17
rm -f wmt17/* wmt17.log

$MRT_MARIAN/marian \
    --type nematus --enc-cell gru-nematus --dec-cell gru-nematus \
    --enc-depth 1 --enc-cell-depth 4 --enc-type bidirectional --dec-depth 1 --dec-cell-base-depth 8 --dec-cell-high-depth 1 \
    --layer-normalization \
    --no-shuffle --seed 1111 --dim-emb 64 --dim-rnn 128 --cost-type ce-mean \
    -m wmt17/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{de,en} -v vocab.en.yml vocab.de.yml \
    --log wmt17.log --disp-freq 2 --after-batches 10

test -e wmt17/model.npz
test -e wmt17/model.npz.yml

cat wmt17.log | $MRT_TOOLS/extract-costs.sh > wmt17.out
$MRT_TOOLS/diff-nums.py wmt17.out wmt17.expected -p 2 -o wmt17.diff

# Exit with success code
exit 0
