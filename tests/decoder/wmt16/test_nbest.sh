#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -b 5 --n-best < text.in > nbest.out
$MRT_TOOLS/diff-floats.py nbest.out nbest.expected > nbest.diff

# Exit with success code
exit 0
