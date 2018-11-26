#!/bin/bash

# Exit on error
set -e

rm -f transformer.out

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/transformer/decode.yml -b 6 < text.in > transformer.out

$MRT_TOOLS/diff.sh transformer.out text.b6.expected > transformer.diff

# Exit with success code
exit 0
