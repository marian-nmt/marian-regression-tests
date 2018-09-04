#!/bin/bash -x

# Exit on error
set -eo pipefail

clean_up() {
    rm -rf nowrite
}
trap clean_up EXIT

# Test code goes here
mkdir -p nowrite
chmod a-w nowrite

$MRT_MARIAN/build/marian \
    -m nowrite/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.en $MRT_DATA/europarl.de-en/corpus.bpe.de \
    --no-shuffle --after-batches 1 \
    > nopermission.log 2>&1 || true

test -e nopermission.log
grep -q "No write permission" nopermission.log

# Exit with success code
exit 0
