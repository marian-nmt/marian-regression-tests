#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on TSV data with guided alignment
# TAGS: sentencepiece tsv train align
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_align0 train_align0.{log,out,diff}
mkdir -p train_align0

# Run marian command
$MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --clip-norm 0 --seed 5555 --maxi-batch 1 --maxi-batch-sort none --optimizer adam --learn-rate 0.001 \
    --dim-emb 32 --transformer-dim-ffn 64 --type transformer --enc-depth 3 --dec-depth 3 \
    -m train_align0/model.npz --tsv -t train2.aln-de-en.tsv -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --after-batches 100 --disp-freq 4 \
    --guided-alignment 0 --guided-alignment-weight 1.0 --guided-alignment-cost ce \
    --log train_align0.log


# Check if files exist
test -e train_align0/model.npz
test -e train_align0.log
grep -qi "word alignments from" train_align0.log

# Compare the current output with the expected output
cat train_align0.log | $MRT_TOOLS/extract-costs.sh > train_align0.out
$MRT_TOOLS/diff-nums.py train_align0.out train_align.expected -p 0.01 -o train_align0.diff

# Exit with success code
exit 0
