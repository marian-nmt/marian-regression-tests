#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on data in the TSV format with mini-batch-fit
# TAGS: sentencepiece tsv train mini-batch-fit gcc5-fails sync-sgd
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_fit train_fit.{log,out,diff}
mkdir -p train_fit

# Run marian command
$MRT_MARIAN/marian \
    --cost-type ce-mean --mini-batch-fit -w 500 --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 10 --optimizer sgd --sync-sgd \
    -m train_fit/model.npz --tsv -t train.tsv -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
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
