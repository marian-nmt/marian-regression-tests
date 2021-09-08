#!/bin/bash -x

#####################################################################
# SUMMARY: Training a factored model combining lemma and factors
# embeddings with concatenation
# AUTHOR: pedrodiascoelho
# TAGS: factors
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf factors_concat factors_concat.{log,out,diff}
mkdir -p factors_concat

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --clip-norm 0 \
    --type transformer --factors-combine concat --factors-dim-emb 8 \
    -m factors_concat/model.npz -t toy.bpe.fact.en $MRT_DATA/europarl.de-en/toy.bpe.de -v $MRT_MODELS/factors/vocab.en.fsv vocab.de.yml \
    --disp-freq 5 -e 5 \
    --log factors_concat.log

# Check if files exist
test -e factors_concat/model.npz
test -e factors_concat.log

#Checks correct factor usage
grep -q "Factored embeddings enabled" factors_concat.log
grep -q "Combining lemma and factors embeddings with concatenation enabled" factors_concat.log

# Compare the current output with the expected output
cat factors_concat.log | $MRT_TOOLS/extract-costs.sh > factors_concat.out
$MRT_TOOLS/diff-nums.py factors_concat.out factors_concat.expected -o factors_concat.diff

# Exit with success code
exit 0
