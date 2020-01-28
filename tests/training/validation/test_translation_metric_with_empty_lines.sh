#!/bin/bash -x

#####################################################################
# SUMMARY: Check a validation translation output with empty lines
# AUTHOR: snukky
# TAGS: valid emptyline
#####################################################################

# Exit on error
set -e

# Skip if compiled without SentencePiece
if [ ! $MRT_MARIAN_USE_SENTENCEPIECE ]; then
    exit 100
fi

# Clean artifacts
rm -rf trans_empty_lines/model.npz* trans_empty_lines.{log,out}
mkdir -p trans_empty_lines

# Copy model and vocab
test -e trans_empty_lines/model.npz || cp $MRT_MODELS/rnn-spm/model.npz trans_empty_lines/model.npz
test -e trans_empty_lines/vocab.spm || cp $MRT_MODELS/rnn-spm/vocab.deen.spm trans_empty_lines/vocab.spm

# Prepare training data
test -e trans_empty_lines/train.de || cat $MRT_DATA/train.max50.de | sed 's/@@ //g' > trans_empty_lines/train.de
test -e trans_empty_lines/train.en || cat $MRT_DATA/train.max50.en | sed 's/@@ //g' > trans_empty_lines/train.en

# Train
$MRT_MARIAN/marian \
    --seed 2222 --no-shuffle --mini-batch 32 --maxi-batch 1 --optimizer sgd \
    -m trans_empty_lines/model.npz -t trans_empty_lines/train.{de,en} -v trans_empty_lines/vocab.{spm,spm} \
    --disp-freq 20 --valid-freq 60 --after-batches 60 \
    --valid-metrics cross-entropy translation --valid-translation-output trans_empty_lines.out \
    --valid-sets trans_empty_lines.de trans_empty_lines.en \
    --valid-log trans_empty_lines.log

test -e trans_empty_lines.log
test -e trans_empty_lines.out

# Compare translation outputs
$MRT_TOOLS/diff.sh trans_empty_lines.out trans_empty_lines.expected > trans_empty_lines.diff

# Exit with success code
exit 0
