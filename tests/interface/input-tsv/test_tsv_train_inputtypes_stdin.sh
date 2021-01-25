#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on data in the TSV format from STDIN with input-types
# TAGS: sentencepiece tsv train inputtypes
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_intypes_stdin train_intypes_stdin.{log,out,diff}
mkdir -p train_intypes_stdin

# Run marian command
cat train.tsv | $MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd \
    -m train_intypes_stdin/model.npz --tsv -t stdin --input-types sequence sequence -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-batches 10 --disp-freq 2 \
    --log train_intypes_stdin.log

# Check if files exist
test -e train_intypes_stdin/model.npz
test -e train_intypes_stdin.log

# Compare the current output with the expected output
cat train_intypes_stdin.log | $MRT_TOOLS/extract-costs.sh > train_intypes_stdin.out
$MRT_TOOLS/diff-nums.py train_intypes_stdin.out train.expected -p 0.01 -o train_intypes_stdin.diff

# Exit with success code
exit 0
