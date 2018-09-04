#!/bin/bash

# Exit on error
set -e

# Run Marian
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -b 6 -n 1.0 < text.b6n.in > marian.b6n.out

# Compare with Marian and Nematus
diff $(pwd)/marian.b6n.out $(pwd)/marian.b6n.expected | tee $(pwd)/marian.b6n.diff | head
diff $(pwd)/marian.b6n.out $(pwd)/nematus.b6n.out | tee $(pwd)/nematus.b6n.diff | head

# Exit with success code
exit 0
