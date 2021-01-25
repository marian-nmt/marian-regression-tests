#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model from TSV input and create YAML vocabularies
# TAGS: tsv train
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_vocabs_yml train_vocabs_yml.*{log,out,diff}
mkdir -p train_vocabs_yml

# Run marian command
$MRT_MARIAN/marian \
    --cost-type ce-mean --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd \
    -m train_vocabs_yml/model.npz --tsv -t train.bpe.tsv -v train_vocabs_yml/vocab.de.yml train_vocabs_yml/vocab.en.yml --dim-vocabs 2000 2000 -T train_vocabs_yml \
    --after-batches 20 --disp-freq 2 \
    --log train_vocabs_yml.log

# Check if files exist
test -e train_vocabs_yml/model.npz
test -e train_vocabs_yml/vocab.de.yml
test -e train_vocabs_yml/vocab.en.yml
test -e train_vocabs_yml.log

# Compare the current output with the expected output
cat train_vocabs_yml.log | $MRT_TOOLS/extract-costs.sh > train_vocabs_yml.out
$MRT_TOOLS/diff-nums.py train_vocabs_yml.out train_vocabs_yml.expected -p 0.01 -o train_vocabs_yml.diff

# Compare vocabularies
$MRT_TOOLS/diff.sh train_vocabs_yml/vocab.de.yml train_vocabs_yml.de.yml.expected -o train_vocabs_yml.de.yml.diff
$MRT_TOOLS/diff.sh train_vocabs_yml/vocab.en.yml train_vocabs_yml.en.yml.expected -o train_vocabs_yml.en.yml.diff

# Exit with success code
exit 0
