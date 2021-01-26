#!/bin/bash -x

#####################################################################
# SUMMARY: Make sure that the resulting model is in quantized form
# AUTHOR: afaji
# TAGS: clip-norm
#####################################################################

# Exit on error
set -e

PREFIX=test-center

# Remove old artifacts and create working directory
rm -rf train
mkdir -p train

# Train an 8-bits model
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --learn-rate 0.1 --optimizer sgd --clip-norm 1 \
    -m train/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v train/vocab.en.yml train/vocab.de.yml \
    --cost-type cross-entropy --sync-sgd --after-batches 10 --disp-freq 2 --quantize-bits 3

# Check if files exist
test -e train/model.npz

# make sure that the resulting model has no more than 256 different values (i.e. quantized)
$MRT_TOOLS/check-model-unique-vals.py train/model.npz -b 3 --print_centers -o model_centers.out
$MRT_TOOLS/diff-nums.py model_centers.out model_centers.expected -o model_centers.diff --numpy

# Exit with success code
exit 0
