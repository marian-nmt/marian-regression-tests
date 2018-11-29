#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf empty_valid_lm empty_valid_lm.log empty_valid.??

mkdir -p empty_valid_lm
touch empty_valid.en

$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --optimizer sgd --dim-emb 64 --dim-rnn 128 \
    --model empty_valid_lm/model.npz --type lm \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.en -v vocab.en.yml \
    --disp-freq 2 --valid-freq 4 --after-batches 20 \
    --valid-metrics perplexity --valid-sets empty_valid.en \
    > empty_valid_lm.log 2>&1 || true

test -e empty_valid_lm.log
grep -qi "file .* empty" empty_valid_lm.log

# Exit with success code
exit 0
