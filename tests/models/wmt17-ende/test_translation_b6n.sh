#!/bin/bash

# Exit on error
set -e

rm -f marian.b6n.out

# Run Marian
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt17_systems/marian.en-de.yml -b 6 -n 1.0 < text.b6n.in > marian.b6n.out

# Compare with Marian
diff marian.b6n.out marian.b6n.expected > marian.b6n.diff

# Compare with Nematus
# The very first line is ommitted as it may differ due to a bug with GPU memory allocation
diff <(tail -n +2 marian.b6n.out) <(tail -n +2 nematus.b6n.out) > nematus.b6n.diff

# Exit with success code
exit 0
