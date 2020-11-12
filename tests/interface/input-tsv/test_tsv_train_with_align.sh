#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on TSV data with guided alignment
# TAGS: sentencepiece tsv train align
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_align train_align.{log,out,diff}
mkdir -p train_align

# Run marian command
$MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --seed 5555 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --learn-rate 0.1 \
    -m train_align/model.npz --tsv -t train2.de-en-aln.tsv -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-batches 100 --disp-freq 4 \
    --guided-alignment 2 --guided-alignment-weight 1.0 \
    --log train_align.log


# Check if files exist
test -e train_align/model.npz
test -e train_align.log
grep -qi "word alignments from" train_align.log

# Compare the current output with the expected output
cat train_align.log | $MRT_TOOLS/extract-costs.sh > train_align.out
$MRT_TOOLS/diff-nums.py train_align.out train_align.expected -p 0.01 -o train_align.diff

# Exit with success code
exit 0
