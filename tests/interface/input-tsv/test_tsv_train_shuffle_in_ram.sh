#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model with shuffling-in-RAM training sentences from a TSV file
# TAGS: sentencepiece tsv train gcc5-fails
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_shuffle_ram train_shuffle_ram.{log,out,diff}
mkdir -p train_shuffle_ram

# Run marian command
$MRT_MARIAN/marian \
    --cost-type ce-mean --shuffle-in-ram --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 10 --optimizer sgd \
    -m train_shuffle_ram/model.npz --tsv --tsv-fields 2 -t train.tsv -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-batches 20 --disp-freq 4 \
    --log train_shuffle_ram.log

# Check if files exist
test -e train_shuffle_ram/model.npz
test -e train_shuffle_ram.log

# Compare the current output with the expected output
cat train_shuffle_ram.log | $MRT_TOOLS/extract-costs.sh > train_shuffle_ram.out
$MRT_TOOLS/diff-nums.py train_shuffle_ram.out train_shuffle.expected -p 0.01 -o train_shuffle_ram.diff

# Exit with success code
exit 0
