#!/bin/bash -x

#####################################################################
# SUMMARY: Test the option for resetting all validation metrics after the training is resumed
# AUTHOR: snukky
# TAGS: restore valid valid-script valid-reset
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf valid_reset_all valid_reset_all_?.*log valid_script_?.temp
mkdir -p valid_reset_all

test -s valid.mini.bpe.en || head -n 8 $MRT_DATA/europarl.de-en/toy.bpe.en > valid.mini.bpe.en
test -s valid.mini.bpe.de || head -n 8 $MRT_DATA/europarl.de-en/toy.bpe.de > valid.mini.bpe.de

extra_opts="--no-shuffle --seed 2222 --maxi-batch 1 --maxi-batch-sort none --quiet-translation"
extra_opts="$extra_opts --dim-emb 64 --dim-rnn 128 --mini-batch 16 --optimizer sgd"
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"


# Train a model for a while and stop
$MRT_MARIAN/marian $extra_opts \
    -m valid_reset_all/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --valid-freq 20 --after-batches 140 --early-stopping 5 \
    --valid-metrics translation valid-script cross-entropy --valid-script-path ./valid_script_ab.sh \
    --valid-sets valid.mini.bpe.{de,en} \
    --overwrite --keep-best --clip-norm 0 \
    --log valid_reset_all_1.log

test -e valid_reset_all/model.npz
test -e valid_reset_all/model.npz.yml
test -e valid_reset_all_1.log

cp valid_reset_all/model.npz.progress.yml valid_reset_all/model.npz.progress.yml.bak

cat valid_reset_all_1.log | $MRT_TOOLS/strip-timestamps.sh | grep -P "\[valid\]" > valid_reset_all.out


# Restart training with --valid-reset-all
$MRT_MARIAN/marian $extra_opts \
    -m valid_reset_all/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --valid-freq 20 --after-batches 200 --early-stopping 5 --valid-reset-all \
    --valid-metrics translation valid-script cross-entropy --valid-script-path ./valid_script_ab.sh \
    --valid-sets valid.mini.bpe.{de,en} \
    --overwrite --keep-best --clip-norm 0 \
    --log valid_reset_all_2.log

test -e valid_reset_all/model.npz
test -e valid_reset_all_2.log

cat valid_reset_all_2.log | $MRT_TOOLS/strip-timestamps.sh | grep -P "\[valid\]" >> valid_reset_all.out


# Compare with the expected output
$MRT_TOOLS/diff.sh valid_reset_all.out valid_reset_all.expected > valid_reset_all.diff

# Exit with success code
exit 0
