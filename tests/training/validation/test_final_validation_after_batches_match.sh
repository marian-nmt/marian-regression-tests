#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf final_match final_match.log vocab.*.yml
mkdir -p final_match

$MRT_MARIAN/build/marian \
    --no-shuffle --seed 1111 -o sgd --dim-emb 64 --dim-rnn 128 \
    -m final_match/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} \
    -v vocab.en.yml vocab.de.yml --dim-vocabs 50000 50000 \
    --disp-freq 30 --valid-freq 60 --after-batches 180 \
    --valid-metrics cross-entropy --valid-sets valid.bpe.{en,de} \
    --valid-log final_match.log

test -e final_match/model.npz
test -e final_match.log

$MRT_TOOLS/strip-timestamps.sh < final_match.log > final_match.out
$MRT_TOOLS/diff-floats.py $(pwd)/final_match.out $(pwd)/final_match.expected -p 0.9 | tee $(pwd)/final_match.diff | head

# Exit with success code
exit 0
