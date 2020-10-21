#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model from TSV input and create vocabularies
# TAGS: sentencepiece tsv train
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_vocabs train_vocabs.*{log,out,diff}
mkdir -p train_vocabs

# Run marian command
$MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd \
    -m train_vocabs/model.npz --tsv -t train.tsv -v train_vocabs/vocab.de.spm train_vocabs/vocab.en.spm --dim-vocabs 2000 2000 -T train_vocabs \
    --after-batches 20 --disp-freq 2 \
    --log train_vocabs.log

# Check if files exist
test -e train_vocabs/model.npz
test -e train_vocabs/vocab.de.spm
test -e train_vocabs/vocab.en.spm
test -e train_vocabs.log

# Compare the current output with the expected output
cat train_vocabs.log | $MRT_TOOLS/extract-costs.sh > train_vocabs.out
$MRT_TOOLS/diff-nums.py train_vocabs.out train_vocabs.expected -p 0.1 -o train_vocabs.diff

# Compare vocabularies
# WARNING: This seems not deterministic across compilations
#$MRT_MARIAN/spm_export_vocab -model train_vocabs/vocab.de.spm > train_vocabs.de.spm.out
#$MRT_MARIAN/spm_export_vocab -model train_vocabs/vocab.en.spm > train_vocabs.en.spm.out

#$MRT_TOOLS/diff-nums.py train_vocabs.de.spm.out train_vocabs.de.spm.expected -p 0.01 -o train_vocabs.de.spm.diff
#$MRT_TOOLS/diff-nums.py train_vocabs.en.spm.out train_vocabs.en.spm.expected -p 0.01 -o train_vocabs.en.spm.diff

# Exit with success code
exit 0
