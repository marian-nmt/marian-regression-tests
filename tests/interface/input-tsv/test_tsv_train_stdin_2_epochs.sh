#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on data in the TSV format from STDIN without shuffling
# TAGS: sentencepiece tsv train
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_stdin_2e train_stdin_2e.{log,out,diff}
mkdir -p train_stdin_2e

# Train for the 1st epoch
cat train.tsv | $MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd \
    -m train_stdin_2e/model.npz --tsv -t stdin -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --disp-freq 5 \
    --log train_stdin_2e.log

# Check if files exist
test -e train_stdin_2e/model.npz
test -e train_stdin_2e.log

# Train for the 2nd epoch
cat train.tsv | $MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --learn-rate 0.002 \
    -m train_stdin_2e/model.npz --tsv -t stdin -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --disp-freq 5 \
    --log train_stdin_2e.log

# Compare the current output with the expected output
cat train_stdin_2e.log | $MRT_TOOLS/extract-costs.sh > train_stdin_2e.out
$MRT_TOOLS/diff-nums.py train_stdin_2e.out train_stdin_2e.expected -p 0.01 -o train_stdin_2e.diff

# Exit with success code
exit 0
