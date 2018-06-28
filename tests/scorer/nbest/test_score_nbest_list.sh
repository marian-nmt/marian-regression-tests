#!/bin/bash

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/build/marian-scorer \
    -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -m en-de/model.npz \
    --n-best -t $(pwd)/text.src.in $(pwd)/text.nbest.in \
    > nbest.out

$MRT_TOOLS/diff-floats.py nbest.out nbest.expected -p 0.0003 > nbest.diff

# Exit with success code
exit 0
