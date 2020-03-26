#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model providing training sentences in a TSV file
# TAGS: sentencepiece tsv train
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_stdin train_stdin.{log,out,diff}
mkdir -p train_stdin

test -s train.de  || cat $MRT_DATA/train.max50.de | sed 's/@@ //g' > train.de
test -s train.en  || cat $MRT_DATA/train.max50.en | sed 's/@@ //g' > train.en
paste train.{de,en} > train.tsv

# Run marian command
cat train.tsv | $MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd \
    -m train_stdin/model.npz --tsv --tsv-size 2 -t stdin -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-batches 10 --disp-freq 2 \
    --log train_stdin.log

# Check if files exist
test -e train_stdin/model.npz
test -e train_stdin.log

# Compare the current output with the expected output
cat train_stdin.log | $MRT_TOOLS/extract-costs.sh > train_stdin.out
$MRT_TOOLS/diff-nums.py train_stdin.out train.expected -p 0.1 -o train_stdin.diff

# Exit with success code
exit 0
