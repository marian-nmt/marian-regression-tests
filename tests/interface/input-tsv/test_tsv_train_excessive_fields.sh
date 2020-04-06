#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on data from a TSV file with excessive fields
# TAGS: sentencepiece tsv train_extra_tabs
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_extra_tabs train_extra_tabs.{log,out,diff}
mkdir -p train_extra_tabs

paste train.{de,en} \
    | sed '100,120s/ /\t/' \
    | sed '200,220s/\t/\t\t/' \
    | sed '300,320s/^/\t/' \
    > train_extra_tabs.tsv

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd \
    -m train_extra_tabs/model.npz --tsv -t train_extra_tabs.tsv -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-batches 10 --disp-freq 2 \
    --log train_extra_tabs.log

# Check if files exist
test -e train_extra_tabs/model.npz
test -e train_extra_tabs.log

# Compare the current output with the expected output
cat train_extra_tabs.log | $MRT_TOOLS/strip-timestamps.sh | grep -i 'warn.*excessive field' > train_extra_tabs.out
$MRT_TOOLS/diff.sh train_extra_tabs.out train_extra_tabs.expected > train_extra_tabs.diff

# Exit with success code
exit 0
