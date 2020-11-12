#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on data in the TSV format from STDIN without shuffling
# TAGS: sentencepiece tsv train
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_stdin train_stdin.{log,out,diff}
mkdir -p train_stdin

# Run marian command
cat train.tsv | $MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd \
    -m train_stdin/model.npz --tsv -t stdin -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-batches 10 --disp-freq 2 \
    --log train_stdin.log

# Check if files exist
test -e train_stdin/model.npz
test -e train_stdin.log

# Compare the current output with the expected output
cat train_stdin.log | $MRT_TOOLS/extract-costs.sh > train_stdin.out
$MRT_TOOLS/diff-nums.py train_stdin.out train.expected -p 0.01 -o train_stdin.diff

# Exit with success code
exit 0
