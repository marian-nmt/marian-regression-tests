#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on data from a TSV file
# TAGS: sentencepiece tsv train
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train train.{log,out,diff}
mkdir -p train

# Run marian command
$MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd \
    -m train/model.npz --tsv -t train.tsv -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-batches 10 --disp-freq 2 \
    --log train.log

# Check if files exist
test -e train/model.npz
test -e train.log

# Compare the current output with the expected output
cat train.log | $MRT_TOOLS/extract-costs.sh > train.out
$MRT_TOOLS/diff-nums.py train.out train.expected -p 0.01 -o train.diff

# Exit with success code
exit 0
