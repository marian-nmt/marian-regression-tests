#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model from TSV input and create a joint vocabulary
# TAGS: sentencepiece tsv train
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_vocab train_vocab.{log,out,diff}
mkdir -p train_vocab

# Run marian command
$MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd \
    -m train_vocab/model.npz --tsv -t train.tsv -v train_vocab/vocab.spm train_vocab/vocab.spm --dim-vocabs 2000 2000 -T train_vocab \
    --after-batches 20 --disp-freq 2 \
    --log train_vocab.log

# Check if files exist
test -e train_vocab/model.npz
test -e train_vocab/vocab.spm
test -e train_vocab.log

# Compare the current output with the expected output
# Note: A large precision is set because creation of SentencePiece vocabs seems not fully deterministic
cat train_vocab.log | $MRT_TOOLS/extract-costs.sh > train_vocab.out
$MRT_TOOLS/diff-nums.py train_vocab.out train_vocab.expected -p 2.0 -o train_vocab.diff

# Exit with success code
exit 0
