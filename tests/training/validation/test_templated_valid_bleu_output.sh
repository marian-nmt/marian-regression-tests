#!/bin/bash -x

#####################################################################
# SUMMARY: Templated file names for translation outputs with BLEU
# AUTHOR: snukky
#####################################################################


# Exit on error
set -e

# Remove temporary files
rm -rf template_bleu template_bleu.log vocab.small.*.yml valid-bleu-output-*.out
mkdir -p template_bleu

# Prepare training data if it doesn't exist
test -e train.bpe.en || head -n 3000 $MRT_DATA/europarl.de-en/corpus.bpe.en > train.bpe.en
test -e train.bpe.de || head -n 3000 $MRT_DATA/europarl.de-en/corpus.bpe.de > train.bpe.de


# Run Marian using --valid-translation-output with templates
$MRT_MARIAN/marian \
    --no-shuffle --seed 2222 --optimizer sgd --dim-emb 64 --dim-rnn 128 \
    -m template_bleu/model.npz -t train.bpe.{en,de} \
    -v vocab.small.en.yml vocab.small.de.yml \
    --mini-batch 32 --disp-freq 20 --valid-freq 40 --after-batches 150 \
    --valid-sets valid.bpe.{en,de} \
    --valid-metrics bleu \
    --valid-translation-output valid-bleu-output-epoch-{E}-batch-{B}-updates-{U}-tokens-{T}.out \
    --valid-log template_bleu.log

test -e template_bleu.log

# Check if validation outputs have expected names
test -s valid-bleu-output-epoch-1-batch-40-updates-40-tokens-41764.out
test -s valid-bleu-output-epoch-1-batch-80-updates-80-tokens-60798.out
test -s valid-bleu-output-epoch-2-batch-39-updates-120-tokens-101878.out


# Exit with success code
exit 0
