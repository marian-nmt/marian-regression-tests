#!/bin/bash -x

#####################################################################
# SUMMARY: Training a factored model 
# AUTHOR: pedrodiascoelho
# TAGS: factors
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf factors factors.{log,out,diff}
mkdir -p factors

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --clip-norm 0 \
    -m factors/model.npz -t toy.bpe.fact.{en,de} -v $MRT_MODELS/factors/vocab.{en,de}.fsv \
    --disp-freq 5 -e 5 \
    --log factors.log

# Check if files exist
test -e factors/model.npz
test -e factors.log
grep -q "Factored embeddings enabled" factors.log
grep -q "Factored outputs enabled" factors.log

# Compare the current output with the expected output
cat factors.log | $MRT_TOOLS/extract-costs.sh > factors.out
$MRT_TOOLS/diff-nums.py factors.out factors.expected -o factors.diff

# Exit with success code
exit 0
