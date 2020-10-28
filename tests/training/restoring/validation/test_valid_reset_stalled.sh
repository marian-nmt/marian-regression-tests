#!/bin/bash -x

#####################################################################
# SUMMARY: Test the option for resetting stalled validations after the training is resumed
# AUTHOR: snukky
# TAGS: restore valid validscript validreset
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf valid_reset_stalled valid_reset_stalled_?.*log valid_script_?.temp
mkdir -p valid_reset_stalled

test -s valid.mini.bpe.en || head -n 8 $MRT_DATA/europarl.de-en/toy.bpe.en > valid.mini.bpe.en
test -s valid.mini.bpe.de || head -n 8 $MRT_DATA/europarl.de-en/toy.bpe.de > valid.mini.bpe.de

extra_opts="--no-shuffle --seed 2222 --maxi-batch 1 --maxi-batch-sort none --quiet-translation"
extra_opts="$extra_opts --dim-emb 64 --dim-rnn 128 --mini-batch 16 --optimizer sgd"
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"


# Train a model for a while and stop
$MRT_MARIAN/marian $extra_opts \
    -m valid_reset_stalled/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --valid-freq 20 --after-batches 140 --early-stopping 5 \
    --valid-metrics translation valid-script cross-entropy --valid-script-path ./valid_script_ab.sh \
    --valid-sets valid.mini.bpe.{de,en} \
    --overwrite --keep-best \
    --log valid_reset_stalled_1.log

test -e valid_reset_stalled/model.npz
test -e valid_reset_stalled/model.npz.yml
test -e valid_reset_stalled_1.log

cat valid_reset_stalled_1.log | $MRT_TOOLS/strip-timestamps.sh | grep -P "\[valid\]" > valid_reset_stalled.out


# Restart training with --valid-reset-stalled
$MRT_MARIAN/marian $extra_opts \
    -m valid_reset_stalled/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --valid-freq 20 --after-batches 200 --early-stopping 5 --valid-reset-stalled \
    --valid-metrics translation valid-script cross-entropy --valid-script-path ./valid_script_ab.sh \
    --valid-sets valid.mini.bpe.{de,en} \
    --overwrite --keep-best \
    --log valid_reset_stalled_2.log

test -e valid_reset_stalled/model.npz
test -e valid_reset_stalled_2.log

cat valid_reset_stalled_2.log | $MRT_TOOLS/strip-timestamps.sh | grep -P "\[valid\]" >> valid_reset_stalled.out


# Compare with the expected output
$MRT_TOOLS/diff.sh valid_reset_stalled.out valid_reset_stalled.expected > valid_reset_stalled.diff

# Exit with success code
exit 0
