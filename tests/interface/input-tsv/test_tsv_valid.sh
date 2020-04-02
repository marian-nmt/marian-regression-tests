#!/bin/bash -x

#####################################################################
# SUMMARY: Provide validation set in TSV format
# TAGS: valid tsv sentencepiece
#####################################################################

# Exit on error
set -e

# Clean artifacts
rm -rf valid/model.npz* valid.{log,out}
mkdir -p valid

# Copy model and vocab
test -e valid/model.npz || cp $MRT_MODELS/rnn-spm/model.npz valid/model.npz
test -e valid/vocab.spm || cp $MRT_MODELS/rnn-spm/vocab.deen.spm valid/vocab.spm

# Prepare training data
test -s train.de  || cat $MRT_DATA/train.max50.de | sed 's/@@ //g' > train.de
test -s train.en  || cat $MRT_DATA/train.max50.en | sed 's/@@ //g' > train.en
test -s train.tsv || paste train.{de,en} > train.tsv

# Train
$MRT_MARIAN/marian \
    --seed 2222 --no-shuffle --mini-batch 32 --maxi-batch 1 --optimizer sgd \
    -m valid/model.npz --tsv -t train.tsv -v valid/vocab.{spm,spm} \
    --disp-freq 20 --valid-freq 30 --after-batches 30 \
    --valid-metrics cross-entropy translation --valid-translation-output valid.out \
    --valid-sets valid.tsv \
    --valid-log valid.log

test -e valid.log
test -e valid.out

# Compare translation outputs
$MRT_TOOLS/diff.sh valid.out valid.expected > valid.diff

# Exit with success code
exit 0
