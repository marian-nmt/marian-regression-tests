#!/bin/bash

# Exit on error
set -e

rm -f batched.out

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/transformer/decode.yml -b 6 --mini-batch 32 < text.in > batched.out

$MRT_TOOLS/diff.sh batched.out text.b6.expected > batched.diff

# Exit with success code
exit 0
