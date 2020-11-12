#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on data in the TSV format from STDIN with mini-batch-fit
# TAGS: sentencepiece tsv train mini-batch-fit
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_fit_stdin train_fit_stdin.{log,out,diff}
mkdir -p train_fit_stdin

# Run marian command
cat train.tsv | $MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --mini-batch-fit -w 500 --seed 2222 --dim-emb 32 --dim-rnn 64 --maxi-batch 10 --optimizer sgd \
    -m train_fit_stdin/model.npz --tsv -t stdin -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --disp-freq 4 --log train_fit_stdin.log

# Check if files exist
test -e train_fit_stdin/model.npz
test -e train_fit_stdin.log

# Compare the current output with the expected output
cat train_fit_stdin.log | $MRT_TOOLS/extract-costs.sh > train_fit_stdin.out
$MRT_TOOLS/diff-nums.py train_fit_stdin.out train_fit_stdin.expected -p 0.01 -o train_fit_stdin.diff

# Exit with success code
exit 0
