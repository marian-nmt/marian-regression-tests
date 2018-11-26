#!/bin/bash -x

#####################################################################
# SUMMARY: Template script for testing Marian training
# AUTHOR: <your-github-username>
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train train.{log,out,diff}
mkdir -p train

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none \
    -m train/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v train/vocab.en.yml train/vocab.de.yml \
    --after-batches 10 --disp-freq 2 \
    --log train.log

# Check if files exist
test -e train/model.npz
test -e train.log

# Compare the current output with the expected output
cat train.log | $MRT_TOOLS/extract-costs.sh > train.out
$MRT_TOOLS/diff-nums.py train.out train.expected -o train.diff

# Exit with success code
exit 0
