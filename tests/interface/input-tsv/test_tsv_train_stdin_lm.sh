#!/bin/bash -x

#####################################################################
# SUMMARY: Train a language model on data from a TSV file
# TAGS: sentencepiece tsv train lm
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_lm train_lm.{log,out,diff}
mkdir -p train_lm

# Run marian command
cat train.en | $MRT_MARIAN/marian --type lm \
    --cost-type ce-mean --no-shuffle --seed 4444 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd \
    -m train_lm/model.npz -t stdin -v $MRT_MODELS/rnn-spm/vocab.deen.spm \
    --after-batches 10 --disp-freq 2 \
    --log train_lm.log

# Check if files exist
test -e train_lm/model.npz
test -e train_lm.log

# Compare the current output with the expected output
cat train_lm.log | $MRT_TOOLS/extract-costs.sh > train_lm.out
$MRT_TOOLS/diff-nums.py train_lm.out train_lm.expected -p 0.01 -o train_lm.diff

# Exit with success code
exit 0
