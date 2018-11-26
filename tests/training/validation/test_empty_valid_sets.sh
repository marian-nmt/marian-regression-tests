#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf empty_validsets empty_validsets.log empty_valid.??

mkdir -p empty_validsets
touch empty_valid.en
touch empty_valid.de

$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --optimizer sgd --dim-emb 64 --dim-rnn 128 \
    --model empty_validsets/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 2 --valid-freq 4 --after-batches 20 \
    --valid-metrics ce-mean-words bleu --valid-sets empty_valid.{en,de} \
    > empty_validsets.log 2>&1 || true

test -e empty_validsets.log
grep -qi "file .* empty" empty_validsets.log

# Exit with success code
exit 0
