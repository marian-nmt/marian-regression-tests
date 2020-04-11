#!/bin/bash -x

#####################################################################
# SUMMARY: Report an error if the tab-separated training data has a line with excessive fields
# TAGS: sentencepiece tsv train
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
    > train_extra_tabs.log 2>&1 || true

test -e train_extra_tabs.log
grep -qi "excessive field" train_extra_tabs.log

# Exit with success code
exit 0
