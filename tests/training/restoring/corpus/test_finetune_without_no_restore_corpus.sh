#!/bin/bash -x

#####################################################################
# SUMMARY: Fine-tuning on another data with corpus restoration returns a useful error message
# AUTHOR: snukky
# TAGS: finetune restore
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf finetune_error finetune_error*.log
mkdir -p finetune_error

test -e vocab.de.yml
test -e vocab.en.yml

extra_opts="--seed 2222 --maxi-batch 1 --maxi-batch-sort none --mini-batch 64 --optimizer sgd --dim-emb 128 --dim-rnn 256 --disp-freq 4"


# Train a model on a training corpus
$MRT_MARIAN/marian \
    -m finetune_error/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 30 $extra_opts \
    --log finetune_error_pretrain.log

test -e finetune_error/model.npz
test -e finetune_error/model.npz.yml
test -e finetune_error/model.npz.progress.yml


# Restart the training on another training corpus without --no-restore-corpus
$MRT_MARIAN/marian \
    -m finetune_error/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 40 $extra_opts --log finetune_error.log || true

test -e finetune_error/model.npz
test -e finetune_error.log

# Check the error message
grep -q "add --no-restore-corpus" finetune_error.log


# Exit with success code
exit 0
