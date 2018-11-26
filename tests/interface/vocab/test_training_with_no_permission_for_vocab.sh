#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf nowrite nowrite.log
mkdir -p nowrite
chmod a-w nowrite

$MRT_MARIAN/marian \
    -v nowrite/vocab.en.yml nowrite/vocab.de.yml \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.en $MRT_DATA/europarl.de-en/corpus.bpe.de \
    --no-shuffle --after-batches 1 \
    > nowrite.log 2>&1 || true

test -e nowrite.log
grep -q "No write permission" nowrite.log

# Exit with success code
exit 0
