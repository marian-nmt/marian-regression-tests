#!/bin/bash -x

#####################################################################
# SUMMARY: Test logical epoch defined via labels
# AUTHOR: snukky
# TAGS: sentencepiece stopping after logical-epoch
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf log_epoch_t log_epoch_t.*{log,out,diff}
mkdir -p log_epoch_t

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none \
    -m log_epoch_t/model.npz -t train.{de,en}.gz -v $MRT_MODELS/rnn-spm/vocab.{deen,deen}.spm \
    --mini-batch 128 --logical-epoch 6kt --log log_epoch_t.log --after 10e \
    --disp-freq 10kt

# Check if files exist
test -e log_epoch_t/model.npz
test -e log_epoch_t.log

# Compare actual and expected outputs
cat log_epoch_t.log | $MRT_TOOLS/strip-timestamps.sh | grep -v '^\[' | sed 's/ : Time.*//' > log_epoch_t.out
$MRT_TOOLS/diff-nums.py log_epoch_t.out log_epoch_t.expected -p 0.01 -o log_epoch_t.diff

# Exit with success code
exit 0
