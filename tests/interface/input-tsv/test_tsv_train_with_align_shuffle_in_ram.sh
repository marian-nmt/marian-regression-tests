#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on shuffled (in RAM) TSV data with guided alignment
# TAGS: sentencepiece tsv train align gcc5-fails
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_align_shuffle_ram train_align_shuffle_ram.{log,out,diff}
mkdir -p train_align_shuffle_ram

# Run marian command
$MRT_MARIAN/marian \
    --cost-type ce-mean --shuffle-in-ram --seed 4444 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --learn-rate 0.1 \
    -m train_align_shuffle_ram/model.npz --tsv -t train2.aln-de-en.tsv -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-batches 100 --disp-freq 4 \
    --guided-alignment 0 --guided-alignment-weight 1.0 \
    --log train_align_shuffle_ram.log

# Check if files exist
test -e train_align_shuffle_ram/model.npz
test -e train_align_shuffle_ram.log
grep -qi "word alignments from" train_align_shuffle_ram.log

# Compare the current output with the expected output
cat train_align_shuffle_ram.log | $MRT_TOOLS/extract-costs.sh > train_align_shuffle_ram.out
$MRT_TOOLS/diff-nums.py train_align_shuffle_ram.out train_align_shuffle.expected -p 0.01 -o train_align_shuffle_ram.diff

# Exit with success code
exit 0
