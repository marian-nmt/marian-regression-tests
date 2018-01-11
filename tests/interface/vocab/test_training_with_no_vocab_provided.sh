#!/bin/bash -x

# Exit on error
set -e

# Remove any files, etc.
clean_up() {
    rm -f $MRT_DATA/europarl.de-en/corpus.bpe.en.yml $MRT_DATA/europarl.de-en/corpus.bpe.de.yml
}
trap clean_up EXIT

# Test code goes here
rm -rf novocab novocab_create.log novocab_load.log
rm -f $MRT_DATA/europarl.de-en/corpus.bpe.en.yml $MRT_DATA/europarl.de-en/corpus.bpe.de.yml

mkdir -p novocab

# Run Marian with no vocabs provided, expect to create new vocabs
$MRT_MARIAN/build/marian \
    -m novocab/model1.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.en $MRT_DATA/europarl.de-en/corpus.bpe.de \
    --no-shuffle --after-batches 1 \
    --log novocab_create.log

test -e $MRT_DATA/europarl.de-en/corpus.bpe.en.yml
test -e $MRT_DATA/europarl.de-en/corpus.bpe.de.yml

test -e novocab_create.log
grep -q "Creating vocabulary" novocab_create.log

# Run Marian with no vocabs provided, expect to load existing vocabs
$MRT_MARIAN/build/marian \
    -m novocab/model2.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.en $MRT_DATA/europarl.de-en/corpus.bpe.de \
    --no-shuffle --after-batches 1 \
    --log novocab_load.log

test -e $MRT_DATA/europarl.de-en/corpus.bpe.en.yml
test -e $MRT_DATA/europarl.de-en/corpus.bpe.de.yml

test -e novocab_load.log
grep -qv "Creating vocabulary" novocab_load.log
grep -q "Loading vocabulary" novocab_load.log

# Exit with success code
exit 0
