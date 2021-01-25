#!/bin/bash -x

#####################################################################
# SUMMARY: Training S2S model with guided alignment
# AUTHOR: snukky
# TAGS: align rnn
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf rnn rnn.{log,out,diff}
mkdir -p rnn

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --cost-type ce-mean \
    -m rnn/model.npz -t corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 100 --disp-freq 10 \
    --guided-alignment corpus.bpe.align --guided-alignment-weight 1.0 --learn-rate 0.1 \
    --log rnn.log

# Check if files exist
test -e rnn/model.npz
test -e rnn.log
grep -qi "word alignments from file" rnn.log

# Compare the current output with the expected output
cat rnn.log | $MRT_TOOLS/extract-costs.sh > rnn.out
$MRT_TOOLS/diff-nums.py rnn.out rnn.expected -o rnn.diff

# Exit with success code
exit 0
