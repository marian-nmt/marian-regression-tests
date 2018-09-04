#!/bin/bash

# Exit on error
set -eo pipefail

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -b 5 --n-best < text.in > nbest.out
$MRT_TOOLS/diff-floats.py $(pwd)/nbest.out $(pwd)/nbest.expected | tee $(pwd)/nbest.diff | head

# Exit with success code
exit 0
