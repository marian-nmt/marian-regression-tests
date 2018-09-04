#!/bin/bash

# Exit on error
set -eo pipefail

# Run Marian
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -b 6 -n 1.0 \
    --mini-batch 64 --maxi-batch 10 --maxi-batch-sort src -w 2500 \
    < text.b6n.in > marian.batch64.out

# Compare with Marian and Nematus
diff $(pwd)/marian.batch64.out $(pwd)/marian.b6n.expected | tee $(pwd)/marian.batch64.diff | head
diff $(pwd)/marian.batch64.out $(pwd)/nematus.b6n.out | tee $(pwd)/nematus.batch64.diff | head

# Exit with success code
exit 0
