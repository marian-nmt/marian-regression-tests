#!/bin/bash

# Exit on error
set -e

rm -f hardalign.out

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/transformer/decode.yml -b 6 --mini-batch 32 --alignment < text.in > hardalign.out

$MRT_TOOLS/diff.sh hardalign.out text.b6.hardalign.expected > hardalign.diff

# Exit with success code
exit 0
