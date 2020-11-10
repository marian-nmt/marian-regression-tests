#!/bin/bash -x

#####################################################################
# SUMMARY: Training transformer model with guided alignment using synchronous SGD
# AUTHOR: snukky
# TAGS: align transformer syncsgd
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf transformer_sync transformer_sync.{log,out,diff}
mkdir -p transformer_sync

# Run marian command
$MRT_MARIAN/marian --type transformer \
    --no-shuffle --seed 2222 --dim-emb 32 --dim-rnn 64 --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --cost-type ce-mean --sync-sgd \
    -m transformer_sync/model.npz -t corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 100 --disp-freq 10 \
    --guided-alignment corpus.bpe.align --guided-alignment-weight 1.0 --learn-rate 0.1 \
    --log transformer_sync.log

# Check if files exist
test -e transformer_sync/model.npz
test -e transformer_sync.log
grep -qi "word alignments from file" transformer_sync.log

# Compare the current output with the expected output
cat transformer_sync.log | $MRT_TOOLS/extract-costs.sh > transformer_sync.out
$MRT_TOOLS/diff-nums.py transformer_sync.out transformer.expected -o transformer_sync.diff

# Exit with success code
exit 0
