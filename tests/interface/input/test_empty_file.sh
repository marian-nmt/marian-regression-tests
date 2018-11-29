#!/bin/bash

# Exit on error
set -e

rm -f empty_file.log empty_file.in
touch empty_file.in

# Test code goes here
$MRT_MARIAN/marian-decoder -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
    --type amun --dim-emb 500 --dim-vocabs 85000 85000 -v $MRT_MODELS/wmt16_systems/en-de/vocab.{en,de}.json \
    -i empty_file.in > empty_file.log 2>&1 || true

test -e empty_file.log
grep -qi "file .* empty" empty_file.log

# Exit with success code
exit 0
