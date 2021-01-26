#!/bin/bash -x

#####################################################################
# SUMMARY: Train a quantized marian model
# AUTHOR: afaji
# TAGS: clip-norm
#####################################################################

# Exit on error
set -e

PREFIX=quantized

# Remove old artifacts and create working directory
rm -rf train $PREFIX.{log,out,diff}
mkdir -p train

# Train an 8-bits model
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --learn-rate 0.1 --optimizer sgd --clip-norm 1 \
    -m train/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v train/vocab.en.yml train/vocab.de.yml \
    --cost-type cross-entropy --sync-sgd --after-batches 100 --disp-freq 10 --quantize-bits 8 \
    --log $PREFIX.log

# Check if files exist
test -e train/model.npz
test -e $PREFIX.log

# Compare the current output with the expected output
cat $PREFIX.log | $MRT_TOOLS/extract-costs.sh > $PREFIX.out
$MRT_TOOLS/diff-nums.py $PREFIX.out $PREFIX.expected -o $PREFIX.diff

# make sure that the resulting model has no more than 256 different values (i.e. quantized)
$MRT_TOOLS/check-model-unique-vals.py train/model.npz -b 8

# Exit with success code
exit 0
