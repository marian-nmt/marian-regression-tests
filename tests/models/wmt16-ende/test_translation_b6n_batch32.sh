#!/bin/bash

# Exit on error
set -e

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -b 6 -n 1.0 \
    --mini-batch 32 --maxi-batch 10 --maxi-batch-sort src -w 2500 \
    < text.b6n.in > marian.batch32.out

# Compare with Marian and Nematus
$MRT_TOOLS/diff.sh marian.batch32.out marian.b6n.expected > marian.batch32.diff
$MRT_TOOLS/diff.sh marian.batch32.out nematus.b6n.out > nematus.batch32.diff

# Exit with success code
exit 0
