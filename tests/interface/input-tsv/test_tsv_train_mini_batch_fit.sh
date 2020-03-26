#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model with mini-batch-fit providing training sentences from a TSV file
# TAGS: sentencepiece tsv train mini-batch-fit
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_fit train_fit.{log,out,diff}
mkdir -p train_fit

test -s train.de  || cat $MRT_DATA/train.max50.de | sed 's/@@ //g' > train.de
test -s train.en  || cat $MRT_DATA/train.max50.en | sed 's/@@ //g' > train.en
paste train.{de,en} > train.tsv

# Run marian command
$MRT_MARIAN/marian \
    --mini-batch-fit -w 500 --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 10 --optimizer sgd \
    -m train_fit/model.npz --tsv --tsv-size 2 -t train.tsv -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-batches 20 --disp-freq 4 \
    --log train_fit.log

# Check if files exist
test -e train_fit/model.npz
test -e train_fit.log

# Compare the current output with the expected output
cat train_fit.log | $MRT_TOOLS/extract-costs.sh > train_fit.out
$MRT_TOOLS/diff-nums.py train_fit.out train_fit.expected -p 0.01 -o train_fit.diff

# Exit with success code
exit 0
