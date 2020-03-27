#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model from TSV input and create a joint vocabulary
# TAGS: sentencepiece tsv train
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_vocab train_vocab.{log,out,diff}
mkdir -p train_vocab

test -s train.de  || cat $MRT_DATA/train.max50.de | sed 's/@@ //g' > train.de
test -s train.en  || cat $MRT_DATA/train.max50.en | sed 's/@@ //g' > train.en
paste train.{de,en} > train.tsv

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd \
    -m train_vocab/model.npz --tsv --tsv-size 2 -t train.tsv -v train_vocab/vocab.spm train_vocab/vocab.spm --dim-vocabs 2000 2000 -T train_vocab \
    --after-batches 20 --disp-freq 2 \
    --log train_vocab.log

# Check if files exist
test -e train_vocab/model.npz
test -e train_vocab/vocab.spm
test -e train_vocab.log

# Compare the current output with the expected output
cat train_vocab.log | $MRT_TOOLS/extract-costs.sh > train_vocab.out
$MRT_TOOLS/diff-nums.py train_vocab.out train_vocab.expected -p 0.01 -o train_vocab.diff

# Exit with success code
exit 0
