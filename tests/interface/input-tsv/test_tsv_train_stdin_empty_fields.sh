#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on data from a STDIN stream with empty lines and fields
# TAGS: sentencepiece tsv train stdin
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_empty_lines train_empty_lines.{log,out,diff}
mkdir -p train_empty_lines

paste train.{de,en} \
    | sed '100,120s/.*//' \
    | sed '200,220s/.*\t/\t/' \
    | sed '300,320s/\t.*/\t/' \
    > train_empty_lines.tsv

# Run marian command
cat train_empty_lines.tsv | $MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --max-length 200 \
    -m train_empty_lines/model.npz --tsv -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-epochs 1 --disp-freq 2 \
    --log train_empty_lines.log

# Check if files exist
test -e train_empty_lines/model.npz
test -e train_empty_lines.log

# Compare the current output with the expected output
cat train_empty_lines.log | $MRT_TOOLS/extract-costs.sh > train_empty_lines.out
$MRT_TOOLS/diff-nums.py train_empty_lines.out train_empty_lines.expected -p 0.01 -o train_empty_lines.diff

# Exit with success code
exit 0
