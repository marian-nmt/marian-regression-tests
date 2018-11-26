#!/bin/bash -x

# Exit on error
set -e

clean_up() {
    rm -rf nowrite
}
trap clean_up EXIT

# Test code goes here
mkdir -p nowrite
chmod a-w nowrite

$MRT_MARIAN/marian \
    -m nowrite/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --no-shuffle --after-batches 1 \
    > nopermission.log 2>&1 || true

test -e nopermission.log
grep -q "No write permission" nopermission.log

# Exit with success code
exit 0
