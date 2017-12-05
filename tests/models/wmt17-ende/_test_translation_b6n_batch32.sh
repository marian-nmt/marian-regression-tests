#!/bin/bash

# Exit on error
set -e

rm -f marian.batch32.out

# Run Marian
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt17_systems/marian.en-de.yml -b 6 -n 1.0 \
    --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 2500 \
    < text.b6n.in > marian.batch32.out

# Compare with Marian
diff marian.batch32.out marian.b6n.expected > marian.batch32.diff

# Compare with Nematus
# The very first line is ommitted as it may differ due to a bug with GPU memory allocation
diff <(tail -n +2 marian.batch32.out) <(tail -n +2 nematus.b6n.out) > nematus.batch32.diff

# Exit with success code
exit 0
