#!/bin/bash

#####################################################################
# SUMMARY:
# TAGS: dataweights
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf noweights* ones*
mkdir -p noweights ones

test -e vocab.de.yml || $MRT_MARIAN/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.de > vocab.de.yml
test -e vocab.en.yml || $MRT_MARIAN/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.en > vocab.en.yml

$MRT_MARIAN/marian \
    --seed 2222 --no-shuffle --dim-emb 128 --dim-rnn 256 --optimizer sgd \
    -m noweights/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v vocab.{de,en}.yml \
    --log noweights.log --disp-freq 5 -e 2

test -e noweights/model.npz
test -e noweights.log
cat noweights.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed -r 's/ Time.*//' > noweights.out

cat $MRT_DATA/europarl.de-en/toy.bpe.en | sed -r 's/.*/1/g' > ones.weights.txt

$MRT_MARIAN/marian \
    --seed 2222 --no-shuffle --dim-emb 128 --dim-rnn 256 --optimizer sgd \
    -m ones/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{de,en} -v vocab.{de,en}.yml \
    --log ones.log --disp-freq 5 -e 2 \
    --data-weighting ones.weights.txt

test -e ones/model.npz
test -e ones.log

cat ones.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed -r 's/ Time.*//' > ones.out
$MRT_TOOLS/diff-nums.py noweights.out ones.out -p 0.1 -o ones.diff

# Exit with success code
exit 0
