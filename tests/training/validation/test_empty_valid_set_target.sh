#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf empty_trg empty_trg.log empty_valid.??

mkdir -p empty_trg
touch empty_valid.de

$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --optimizer sgd --dim-emb 64 --dim-rnn 128 \
    --model empty_trg/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 2 --valid-freq 4 --after-batches 20 \
    --valid-metrics translation --valid-sets valid.bpe.en empty_valid.de --valid-translation-output empty_trg.out \
    > empty_trg.log 2>&1 || true

test -e empty_trg.log
grep -qi "file .* empty" empty_trg.log

# Exit with success code
exit 0
