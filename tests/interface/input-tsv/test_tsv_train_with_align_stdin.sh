#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model on TSV data from STDIN with guided alignment
# TAGS: sentencepiece tsv train align stdin
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_align_stdin train_align_stdin.{log,out,diff}
mkdir -p train_align_stdin

# Run marian command
cat train2.aln-de-en.tsv | $MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --clip-norm 0 --seed 5555 --maxi-batch 1 --maxi-batch-sort none --optimizer adam --learn-rate 0.001 \
    --dim-emb 32 --transformer-dim-ffn 64 --type transformer --enc-depth 3 --dec-depth 3 \
    -m train_align_stdin/model.npz -t stdin -v $MRT_MODELS/rnn-spm/vocab.deen.{spm,spm} \
    --disp-freq 4 \
    --guided-alignment 0 --guided-alignment-weight 1.0 --guided-alignment-cost ce \
    --log train_align_stdin.log


# Check if files exist
test -e train_align_stdin/model.npz
test -e train_align_stdin.log
grep -qi "word alignments from" train_align_stdin.log

# Compare the current output with the expected output
cat train_align_stdin.log | $MRT_TOOLS/extract-costs.sh > train_align_stdin.out
$MRT_TOOLS/diff-nums.py train_align_stdin.out train_align_stdin.expected -p 0.01 -o train_align_stdin.diff

# Exit with success code
exit 0
