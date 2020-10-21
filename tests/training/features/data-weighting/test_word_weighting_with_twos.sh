#!/bin/bash

#####################################################################
# SUMMARY:
# TAGS: dataweights
#####################################################################

# Exit on error
set -e


# Test with data-weighting as command-line arguments
rm -rf word_twos word_twos.{log,out,diff}
mkdir -p word_twos

# Generate a file with weights that each word has a weight 2
cat $MRT_DATA/europarl.de-en/toy.bpe.en | sed -r 's/[^ ]+/2/g' > word_twos.weights.txt

# Train with word weighting
$MRT_MARIAN/marian \
    --seed 1111 --no-shuffle --dim-emb 128 --dim-rnn 256 --optimizer sgd --cost-type ce-mean \
    -m word_twos/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v vocab.{de,en}.yml \
    --log word_twos.log --disp-freq 5 -e 2 \
    --data-weighting word_twos.weights.txt --data-weighting-type word

test -e word_twos/model.npz
test -e word_twos.log

# Compare costs with the expected values
cat word_twos.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed -r 's/ Time.*//' > word_twos.out
$MRT_TOOLS/diff-nums.py word_twos.out word_twos.expected -p 0.1 -o word_twos.diff


# Test with data-weighting via config file
rm -rf word_twos_cfg word_twos_cfg.{log,out,diff}
mkdir -p word_twos_cfg

# Generate config file
echo "data-weighting: word_twos.weights.txt" > word_twos.config.yml
echo "data-weighting-type: word" >> word_twos.config.yml

# Train with word weighting
$MRT_MARIAN/marian \
    --seed 1111 --no-shuffle --dim-emb 128 --dim-rnn 256 --optimizer sgd --cost-type ce-mean \
    -m word_twos_cfg/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v vocab.{de,en}.yml \
    --log word_twos_cfg.log --disp-freq 5 -e 2 \
    -c word_twos.config.yml

# Compare costs with the same expected values as previously
cat word_twos_cfg.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed -r 's/ Time.*//' > word_twos_cfg.out
$MRT_TOOLS/diff-nums.py word_twos_cfg.out word_twos.expected -p 0.1 -o word_twos_cfg.diff


# Exit with success code
exit 0
