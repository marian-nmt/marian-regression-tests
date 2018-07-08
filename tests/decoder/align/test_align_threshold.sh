#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 16 -b 5 --alignment 0.35 < text.in > align_threshold.out
diff align_threshold.out align_threshold.expected > align_threshold.diff

# Exit with success code
exit 0
