#!/bin/bash

# Exit on error
set -e

# Test code goes here
rm -rf version version.log
mkdir -p version

# Train a model
$MRT_MARIAN/marian \
    -m version/model.npz \
    -t $MRT_DATA/europarl.de-en/toy.bpe.{en,de} \
    -v version/vocab.en.yml version/vocab.de.yml \
    --after-batches 1 --log version.log

# Check if the version is logged for newly started training
test -e version.log
grep -qP "creat.* Marian v[1-9]+\.[0-9]+\.[0-9]+.*" version.log
rm -f version.log

# Check if the model contains a version
test -e version/model.npz
python3 $MRT_MARIAN/../scripts/contrib/model_info.py -s -m version/model.npz | grep -qP "version: v[1-9]+\.[0-9]+\.[0-9]+.*"

# Check if the version is printed during decoding
echo "test" | $MRT_MARIAN/marian-decoder \
    -m version/model.npz -v version/vocab.en.yml version/vocab.de.yml \
    --log version.log

test -e version.log
grep -qP "creat.* Marian v[1-9]+\.[0-9]+\.[0-9]+.*" version.log

# Exit with success code
exit 0
