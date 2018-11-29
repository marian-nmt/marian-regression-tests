#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf empty_src empty_src.log empty_valid.??

mkdir -p empty_src
touch empty_valid.en

$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --optimizer sgd --dim-emb 64 --dim-rnn 128 \
    --model empty_src/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 2 --valid-freq 4 --after-batches 20 \
    --valid-metrics translation --valid-sets empty_valid.en valid.bpe.de --valid-translation-output empty_src.out \
    > empty_src.log 2>&1 || true

test -e empty_src.log
grep -qi "file .* empty" empty_src.log

# Exit with success code
exit 0
