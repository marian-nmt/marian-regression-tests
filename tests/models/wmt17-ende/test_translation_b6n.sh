#!/bin/bash

# Exit on error
set -e

rm -f marian.b6n.out

# Run Marian
$MRT_RUN_MARIAN_DECODER -c $MRT_MODELS/wmt17_systems/marian.en-de.yml -b 6 -n 1.0 < text.b6n.in > marian.b6n.out

# Compare with Marian and Nematus
diff marian.b6n.out marian.b6n.expected > marian.b6n.diff
diff marian.b6n.out nematus.b6n.out > nematus.b6n.diff

# Exit with success code
exit 0
