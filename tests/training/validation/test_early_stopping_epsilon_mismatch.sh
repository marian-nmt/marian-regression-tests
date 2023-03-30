#!/bin/bash -x

#####################################################################
# SUMMARY: Check if --early-stopping-epsilon requires the same number of values as --valid-metrics
# AUTHOR: snukky
# TAGS: early-stopping early-stopping-epsilon
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -rf eps_stop_mismatch eps_stop_mismatch.log
mkdir -p eps_stop_mismatch

# Test code goes here
cp $MRT_MODELS/wngt19/model.small.npz eps_stop_on_1st/model.npz

$MRT_MARIAN/marian \
    --seed 2222 --no-shuffle --clip-norm 1 --maxi-batch 1 --mini-batch 32 -w 2500 \
    -m eps_stop_mismatch/model.npz -t $MRT_DATA/europarl.de-en/corpus.small.{de,en}.gz \
    -v $MRT_MODELS/wngt19/en-de.{spm,spm} \
    --disp-freq 5 --valid-freq 10 --after-batches 10 \
    --valid-metrics bleu ce-mean-words perplexity \
    --valid-sets $MRT_MODELS/wngt19/newstest2014.{en,de} \
    --early-stopping 4 --early-stopping-epsilon 0.5 0.1 > eps_stop_mismatch.log 2>&1 || true

# Check error message
test -e eps_stop_mismatch.log
grep -q "early.stopping.epsilon.* must have as many values as .*valid.metrics" eps_stop_mismatch.log

# Exit with success code
exit 0
