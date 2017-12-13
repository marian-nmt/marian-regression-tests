#!/bin/bash -x

# Exit on error
set -e

if (( $MRT_NUM_DEVICES < 2 )); then
    echo "Too few devices available"
    exit 100
fi

# Test code goes here
rm -rf async_sgd async_sgd.log
mkdir -p async_sgd

$MRT_RUN_MARIAN \
    --no-shuffle --seed 1111 \
    --devices 0 1 \
    -m async_sgd/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.en $MRT_DATA/europarl.de-en/corpus.bpe.de \
    -v vocab.en.yml vocab.de.yml \
    --disp-freq 20 --after-batches 400 \
    --log async_sgd.log

test -e vocab.en.yml
test -e vocab.de.yml
test -e async_sgd.log

cat async_sgd.log | $MRT_TOOLS/strip-timestamps.sh | grep -oP "Ep\. 1 .* Cost [0-9.]*" > async_sgd.out
$MRT_TOOLS/diff-floats.py async_sgd.out async_sgd.expected -p 6.00 --max-diff-nums 2 > async_sgd.diff

# Exit with success code
exit 0
