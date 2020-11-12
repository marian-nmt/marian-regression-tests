#!/bin/bash -x

#####################################################################
# SUMMARY: Fine-tuning on another data with --no-restore-corpus
# AUTHOR: snukky
# TAGS: finetune restore gcc5-fails
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf finetune finetune*.log
mkdir -p finetune

test -e vocab.de.yml
test -e vocab.en.yml

extra_opts="--seed 2222 --maxi-batch 1 --maxi-batch-sort none --mini-batch 64 --optimizer sgd --dim-emb 128 --dim-rnn 256 --disp-freq 4"
# Added because default options has changes
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"


# Train a model on a training corpus
$MRT_MARIAN/marian \
    -m finetune/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 30 $extra_opts \
    --log finetune_1.log

test -e finetune/model.npz
test -e finetune/model.npz.yml
test -e finetune/model.npz.progress.yml

cat finetune_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > finetune.out


# Restart the training on another training corpus with --no-restore-corpus
$MRT_MARIAN/marian \
    -m finetune/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 60 $extra_opts --log finetune_2.log \
    --no-restore-corpus

test -e finetune/model.npz
test -e finetune_2.log

cat finetune_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' >> finetune.out


# Compare with the expected output
$MRT_TOOLS/diff-nums.py finetune.out finetune.expected -p 0.1 -o finetune.diff

# Exit with success code
exit 0
