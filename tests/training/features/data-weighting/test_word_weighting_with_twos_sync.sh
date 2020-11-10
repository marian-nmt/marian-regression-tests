#!/bin/bash

#####################################################################
# SUMMARY:
# TAGS: dataweights
#####################################################################

# Exit on error
set -e


# Remove old files
rm -rf word_twos_sync word_twos_sync.{log,out,diff}
mkdir -p word_twos_sync

# Generate a file with weights that each word has a weight 2
cat $MRT_DATA/europarl.de-en/toy.bpe.en | sed -r 's/[^ ]+/2/g' > word_twos_sync.weights.txt

# Train with word weighting
$MRT_MARIAN/marian \
    --seed 1111 --no-shuffle --dim-emb 128 --dim-rnn 256 --optimizer sgd --cost-type ce-mean \
    -m word_twos_sync/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v vocab.{de,en}.yml --sync-sgd \
    --log word_twos_sync.log --disp-freq 5 -e 2 \
    --data-weighting word_twos_sync.weights.txt --data-weighting-type word

test -e word_twos_sync/model.npz
test -e word_twos_sync.log

# Compare costs with the expected values
cat word_twos_sync.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed -r 's/ Time.*//' > word_twos_sync.out
$MRT_TOOLS/diff-nums.py word_twos_sync.out word_twos_sync.expected -p 0.1 -o word_twos_sync.diff


# Exit with success code
exit 0
