#!/bin/bash -x

#####################################################################
# SUMMARY: Train a model from TSV input and create vocabularies under default paths
# TAGS: tsv train
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf train_vocabs_nopaths train_vocabs_nopaths.*{log,out,diff}
mkdir -p train_vocabs_nopaths

cat $MRT_DATA/train.max50.de > train_vocabs_nopaths/train.de
cat $MRT_DATA/train.max50.en > train_vocabs_nopaths/train.en
paste train_vocabs_nopaths/train.{de,en} > train_vocabs_nopaths/train.tsv

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd \
    -m train_vocabs_nopaths/model.npz --tsv -t train_vocabs_nopaths/train.tsv --dim-vocabs 2000 2000 -T train_vocabs_nopaths \
    --after-batches 20 --disp-freq 2 \
    --log train_vocabs_nopaths.log

# Check if files exist
test -e train_vocabs_nopaths/model.npz
test -e train_vocabs_nopaths/train.tsv.yml      # TODO: will need to be replaced by e.g. train.tsv.0.yml train.tsv.1.yml, etc.
test -e train_vocabs_nopaths.log

# TODO: --tsv means that each of de.yml and en.yml is generated from the entire train.tsv.
#   The separate vocabs below have been generated with -t train.de train.en -v de.yml en.yml.
#   Consider building separate vocabs even if --tsv

# Compare the current output with the expected output
#cat train_vocabs_nopaths.log | $MRT_TOOLS/extract-costs.sh > train_vocabs_nopaths.out
#$MRT_TOOLS/diff-nums.py train_vocabs_nopaths.out train_vocabs_nopaths.expected -p 0.01 -o train_vocabs_nopaths.diff

# Compare vocabularies
#$MRT_TOOLS/diff.sh train_vocabs_nopaths/train.de.yml train_vocabs_nopaths.de.yml.expected > train_vocabs_nopaths.de.yml.diff
#$MRT_TOOLS/diff.sh train_vocabs_nopaths/train.en.yml train_vocabs_nopaths.en.yml.expected > train_vocabs_nopaths.en.yml.diff

# Exit with success code
exit 0
