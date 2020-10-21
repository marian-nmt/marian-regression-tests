#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on TSV data with sentence weighting
# TAGS: sentencepiece tsv train dataweights
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_weights train_weights.{log,out,diff}
mkdir -p train_weights

# Run marian command
$MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --seed 5555 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --learn-rate 0.1 \
    -m train_weights/model.npz --tsv -t train2.de-en-w.tsv -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-batches 100 --disp-freq 4 \
    --data-weighting 2 --data-weighting-type sentence \
    --log train_weights.log


# Check if files exist
test -e train_weights/model.npz
test -e train_weights.log
grep -qi "weights from" train_weights.log

# Compare the current output with the expected output
cat train_weights.log | $MRT_TOOLS/extract-costs.sh > train_weights.out
$MRT_TOOLS/diff-nums.py train_weights.out train_weights.expected -p 0.01 -o train_weights.diff

# Exit with success code
exit 0
