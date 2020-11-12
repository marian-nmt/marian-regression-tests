#!/bin/bash

#####################################################################
# SUMMARY: Train a deep RNN model with Nematus-compatible GRU units
# AUTHOR: snukky
# TAGS: nematus
#####################################################################

# Exit on error
set -e

# Test code goes here
mkdir -p encdec_depth
rm -f encdec_depth/* encdec_depth.log

$MRT_MARIAN/marian \
    --type nematus --enc-cell gru-nematus --dec-cell gru-nematus \
    --enc-depth 4 --enc-cell-depth 4 --enc-type bidirectional --dec-depth 4 --dec-cell-base-depth 4 --dec-cell-high-depth 1 \
    --layer-normalization \
    --no-shuffle --seed 1111 --dim-emb 64 --dim-rnn 128 --cost-type ce-mean \
    -m encdec_depth/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{de,en} -v vocab.en.yml vocab.de.yml \
    --log encdec_depth.log --disp-freq 2 --after-batches 10

test -e encdec_depth/model.npz
test -e encdec_depth/model.npz.yml

cat encdec_depth.log | $MRT_TOOLS/extract-costs.sh > encdec_depth.out
$MRT_TOOLS/diff-nums.py encdec_depth.out encdec_depth.expected -p 3 -o encdec_depth.diff

# Exit with success code
exit 0
