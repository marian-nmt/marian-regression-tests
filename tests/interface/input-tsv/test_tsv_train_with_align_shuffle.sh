#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on shuffled TSV data with guided alignment
# TAGS: sentencepiece tsv train align gcc5-fails sync-sgd
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_align_shuffle train_align_shuffle.{log,out,diff}
mkdir -p train_align_shuffle

# Run marian command
$MRT_MARIAN/marian \
    --cost-type ce-mean --seed 4444 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --learn-rate 0.1 --sync-sgd \
    -m train_align_shuffle/model.npz --tsv -t train2.aln-de-en.tsv -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-batches 100 --disp-freq 4 \
    --guided-alignment 0 --guided-alignment-weight 1.0 \
    --log train_align_shuffle.log

# Check if files exist
test -e train_align_shuffle/model.npz
test -e train_align_shuffle.log
grep -qi "word alignments from" train_align_shuffle.log

# Compare the current output with the expected output
cat train_align_shuffle.log | $MRT_TOOLS/extract-costs.sh > train_align_shuffle.out
$MRT_TOOLS/diff-nums.py train_align_shuffle.out train_align_shuffle.expected -p 0.01 -o train_align_shuffle.diff

# Exit with success code
exit 0
