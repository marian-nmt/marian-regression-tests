#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on TSV data with guided alignment and data weighting using input-types
# TAGS: sentencepiece tsv train align dataweights
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_align_weights_intypes train_align_weights_intypes.{log,out,diff}
mkdir -p train_align_weights_intypes

# Run marian command
$MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --seed 7777 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --learn-rate 0.1 \
    -m train_align_weights_intypes/model.npz --tsv -t train2.de-w-aln-en.tsv -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-batches 60 --disp-freq 4 \
    --input-types sequence weight alignment sequence --guided-alignment-weight 1.0 \
    --log train_align_weights_intypes.log

# Check if files exist
test -e train_align_weights_intypes/model.npz
test -e train_align_weights_intypes.log
grep -qi "word alignments from" train_align_weights_intypes.log
grep -qi "weights from" train_align_weights_intypes.log

# Compare the current output with the expected output
cat train_align_weights_intypes.log | $MRT_TOOLS/extract-costs.sh > train_align_weights_intypes.out
$MRT_TOOLS/diff-nums.py train_align_weights_intypes.out train_align_weights.expected -p 0.01 -o train_align_weights_intypes.diff

# Exit with success code
exit 0
