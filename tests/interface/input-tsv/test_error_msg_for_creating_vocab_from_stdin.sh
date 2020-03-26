#!/bin/bash -x

#####################################################################
# SUMMARY: Creating a vocabulary from a TSV input from STDIN in not supported
# TAGS: sentencepiece tsv train
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf msg_train_vocab msg_train_vocab.log
mkdir -p msg_train_vocab

test -s train.de  || cat $MRT_DATA/train.max50.de | sed 's/@@ //g' > train.de
test -s train.en  || cat $MRT_DATA/train.max50.en | sed 's/@@ //g' > train.en
paste train.{de,en} > train.tsv

# Run marian command
cat train.tsv | $MRT_MARIAN/marian \
    --no-shuffle --seed 1111 -m msg_train_vocab/model.npz \
    --tsv --tsv-size 2 -t stdin -v msg_train_vocab/vocab.spm msg_train_vocab/vocab.spm --dim-vocabs 2000 2000 \
    --after-batches 1 \
    > msg_train_vocab.log 2>&1 || true

test -e msg_train_vocab.log
grep -qi "creating vocab.* TSV.* not supported" msg_train_vocab.log

# Exit with success code
exit 0
