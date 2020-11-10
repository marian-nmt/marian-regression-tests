#!/bin/bash -x

#####################################################################
# SUMMARY: Test logical epoch defined via data epoch
# AUTHOR: snukky
# TAGS: sentencepiece stopping after logical-epoch
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf log_epoch_e log_epoch_e.*{log,out,diff}
mkdir -p log_epoch_e

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none \
    -m log_epoch_e/model.npz -t train.{de,en}.gz -v $MRT_MODELS/rnn-spm/vocab.{deen,deen}.spm \
    --mini-batch 256 --logical-epoch 2e --log log_epoch_e.log --after 3e \
    --disp-freq 10u

# Check if files exist
test -e log_epoch_e/model.npz
test -e log_epoch_e.log

# Compare actual and expected outputs
cat log_epoch_e.log | $MRT_TOOLS/strip-timestamps.sh | grep -v '^\[' | sed 's/ : Time.*//' > log_epoch_e.out
$MRT_TOOLS/diff-nums.py log_epoch_e.out log_epoch_e.expected -p 0.01 -o log_epoch_e.diff

# Exit with success code
exit 0
