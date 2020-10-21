#!/bin/bash -x

#####################################################################
# SUMMARY: Training right-left S2S model
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf rnn rnn.{log,out,diff}
mkdir -p rnn

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --cost-type ce-mean \
    -m rnn/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 100 --disp-freq 10 \
    --right-left --log rnn.log

# Check if files exist
test -e rnn/model.npz
test -e rnn.log
grep -qi "right-left: true" rnn.log

# Compare costs with expected costs
cat rnn.log | $MRT_TOOLS/extract-costs.sh > rnn.out
$MRT_TOOLS/diff-nums.py rnn.out rnn.expected -o rnn.diff

# Exit with success code
exit 0
