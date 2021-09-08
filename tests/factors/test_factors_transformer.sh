#!/bin/bash -x

#####################################################################
# SUMMARY: Training a factored model using the transformer model 
# AUTHOR: pedrodiascoelho
# TAGS: factors
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf factors_transformer factors_transformer.{log,out,diff}
mkdir -p factors_transformer

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --clip-norm 0 \
    --type transformer -m factors_transformer/model.npz -t toy.bpe.fact.{en,de} -v $MRT_MODELS/factors/vocab.{en,de}.fsv \
    --disp-freq 5 -e 5 \
    --log factors_transformer.log

# Check if files exist
test -e factors_transformer/model.npz
test -e factors_transformer.log

#Checks factor usage
grep -q "Factored embeddings enabled" factors_transformer.log
grep -q "Factored outputs enabled" factors_transformer.log

# Compare the current output with the expected output
cat factors_transformer.log | $MRT_TOOLS/extract-costs.sh > factors_transformer.out
$MRT_TOOLS/diff-nums.py factors_transformer.out factors_transformer.expected -o factors_transformer.diff

# Exit with success code
exit 0
