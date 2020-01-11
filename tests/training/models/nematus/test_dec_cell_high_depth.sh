#!/bin/bash

#####################################################################
# SUMMARY: Check error message displayed if training the unsupported Nematus architecture
# AUTHOR: snukky
# TAGS: nematus
#####################################################################

# Exit on error
set -e

# Test code goes here
mkdir -p dec_high
rm -f dec_high/* dec_high.log

$MRT_MARIAN/marian \
    --type nematus --enc-cell gru-nematus --dec-cell gru-nematus \
    --enc-depth 2 --enc-cell-depth 2 --enc-type bidirectional --dec-depth 4 --dec-cell-base-depth 4 --dec-cell-high-depth 4 \
    --layer-normalization \
    --no-shuffle --seed 1111 --dim-emb 64 --dim-rnn 128 \
    -m dec_high/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{de,en} -v vocab.en.yml vocab.de.yml \
    --disp-freq 2 --after-batches 10 \
    > dec_high.log 2>&1 || true

grep -q "does not currently support" dec_high.log
# Exit with success code
exit 0
