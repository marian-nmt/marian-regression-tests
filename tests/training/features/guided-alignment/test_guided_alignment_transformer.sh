#!/bin/bash -x

#####################################################################
# SUMMARY: Training transformer model with guided alignment
# AUTHOR: snukky
# TAGS: align transformer
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf transformer transformer.{log,out,diff}
mkdir -p transformer

# Run marian command
$MRT_MARIAN/marian --type transformer \
    --no-shuffle --seed 2222 --dim-emb 32 --dim-rnn 64 --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --cost-type ce-mean \
    -m transformer/model.npz -t corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 100 --disp-freq 10 \
    --guided-alignment corpus.bpe.align --guided-alignment-weight 1.0 --learn-rate 0.1 \
    --log transformer.log

# Check if files exist
test -e transformer/model.npz
test -e transformer.log
grep -qi "word alignments from file" transformer.log

# Compare the current output with the expected output
cat transformer.log | $MRT_TOOLS/extract-costs.sh > transformer.out
$MRT_TOOLS/diff-nums.py transformer.out transformer.expected -o transformer.diff

# Exit with success code
exit 0
