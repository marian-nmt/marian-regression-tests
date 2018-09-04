#!/bin/bash

# Exit on error
set -eo pipefail

# Test code goes here
rm -rf version version.log
mkdir -p version

# Save a model
$MRT_MARIAN/build/marian \
    -m version/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.en $MRT_DATA/europarl.de-en/corpus.bpe.de \
    -v version/vocab.en.yml version/vocab.de.yml \
    --after-batches 1

# Check if the model contains a version
test -e version/model.npz
python3 $MRT_MARIAN/scripts/contrib/model_info.py -s -m version/model.npz | grep -qP "version: v[1-9]+\.[0-9]+\.[0-9]+\+.*"

# Check if the version is printed
echo "test" | $MRT_MARIAN/build/marian-decoder \
    -m version/model.npz -v version/vocab.en.yml version/vocab.de.yml \
    --log version.log

test -e version.log
grep -qP "created with Marian v[1-9]+\.[0-9]+\.[0-9]+\+.*" version.log

# Exit with success code
exit 0
