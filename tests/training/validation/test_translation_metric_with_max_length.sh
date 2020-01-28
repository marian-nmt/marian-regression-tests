#!/bin/bash -x

#####################################################################
# SUMMARY: Check a validation translation for sentences longer than --valid-max-length
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
rm -rf trans_maxlen/model.npz* trans_maxlen.{log,out}
mkdir -p trans_maxlen

# Copy model and vocab
test -e trans_maxlen/model.npz || cp $MRT_MODELS/rnn-spm/model.npz trans_maxlen/model.npz
test -e trans_maxlen/vocab.spm || cp $MRT_MODELS/rnn-spm/vocab.deen.spm trans_maxlen/vocab.spm

# Prepare training data
test -e trans_maxlen/train.de || cat $MRT_DATA/train.max50.de | sed 's/@@ //g' > trans_maxlen/train.de
test -e trans_maxlen/train.en || cat $MRT_DATA/train.max50.en | sed 's/@@ //g' > trans_maxlen/train.en

# Train
$MRT_MARIAN/marian \
    --seed 2222 --no-shuffle --mini-batch 32 --maxi-batch 1 --optimizer sgd --learn-rate 0.0 \
    -m trans_maxlen/model.npz -t trans_maxlen/train.{de,en} -v trans_maxlen/vocab.{spm,spm} \
    --disp-freq 20 --valid-freq 60 --after-batches 60 \
    --valid-metrics cross-entropy translation --valid-translation-output trans_maxlen.out \
    --valid-sets trans_maxlen.de trans_maxlen.en \
    --valid-log trans_maxlen.log --valid-max-length 20

test -e trans_maxlen.log
test -e trans_maxlen.out

# Compare translation outputs
$MRT_TOOLS/diff.sh trans_maxlen.out trans_maxlen.expected > trans_maxlen.diff

# Exit with success code
exit 0
