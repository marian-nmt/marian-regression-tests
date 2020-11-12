#!/bin/bash -x

#####################################################################
# SUMMARY: Training right-left transformer model
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf transformer transformer.{log,out,diff}
mkdir -p transformer

# Run marian command
$MRT_MARIAN/marian --type transformer \
    --no-shuffle --seed 2222 --dim-emb 32 --dim-rnn 64 --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --cost-type ce-mean \
    -m transformer/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 100 --disp-freq 10 \
    --right-left --log transformer.log

# Check if files exist
test -e transformer/model.npz
test -e transformer.log
grep -qi "right-left: true" transformer.log

# Compare costs with expected costs
cat transformer.log | $MRT_TOOLS/extract-costs.sh > transformer.out
$MRT_TOOLS/diff-nums.py transformer.out transformer.expected -o transformer.diff

# Exit with success code
exit 0
