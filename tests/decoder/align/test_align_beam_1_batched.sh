#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 32 -b 1 --alignment < text.in > align.batched.out
diff align.batched.out align.batched.expected > align.batched.diff

# Exit with success code
exit 0
